require_relative "../resolver"

module Schematrix
  module Generators
    module Templates
      # Computes and renders the from_h/to_h round-trip machinery of
      # a generated class. The symmetric dispatch (a Hash loads
      # through the target class's from_h, an instance dumps through
      # its to_h, everything else such as booleans and scalars passes
      # through unchanged) is emitted once per slot shape as a shared
      # class helper taking the target class, and one delegating
      # class method per class-shaped property pins its own target.
      # Map slots coerce their values, array slots their elements.
      #
      # A slot carrying a coercing scalar format converts through a
      # spec: a frozen tree mirroring the type algebra of the slot
      # (scalar leaves, arrays, maps, tuples, unions of branches),
      # interpreted by a coerce_spec helper emitted next to the shared
      # ones. Every rendered formatted type then converts on load and
      # dump. A union whose branches would convert the same JSON type
      # through different coercers cannot be attributed from the value
      # alone and fails the run with CoercionConflictError.
      module Coercions
        include Resolver

        # The helper a plan's kind delegates to.
        SLOT_HELPERS = {
          class: "class_slot",
          array_of: "array_slot",
          map_of: "map_slot",
        }.freeze

        # The plan kinds backed by the shared slot helpers.
        LEGACY_KINDS = SLOT_HELPERS.keys.freeze

        # The plan kinds the coerce_spec interpreter reads.
        INTERPRETER_KINDS = %i[array map tuple union].freeze

        # The JSON value classes a document value has when its schema
        # type claims a coercing entry.
        CLAIM_CLASSES = {
          TYPE_STRING => [String].freeze,
          TYPE_INTEGER => [Integer].freeze,
          TYPE_NUMBER => [Integer, Float].freeze,
          TYPE_BOOLEAN => [TrueClass, FalseClass].freeze,
          TYPE_NULL => [NilClass].freeze,
        }.freeze

        # The coercion plan of every property, as [mangled name,
        # plan] pairs. A plan is [kind, target] with a legacy kind
        # (:class, :array_of, :map_of, target the relative class name)
        # or a spec kind (target the spec subtree), or nil for
        # properties whose values never need conversion.
        def property_coercions
          @property_coercions ||=
            coercion_plans.tap { |plans| assert_helper_names_free(plans) }
        end

        def coercion_plans
          @properties.to_h.map do |name, schema|
            [name, coercion_plan(@path, "properties/#{name}", schema)]
          end
        end

        # Property methods and helpers share the coerce_ namespace: a
        # property whose mangled name is a helper name would override
        # the helper it and its siblings delegate to. The interpreter
        # and the catch-all join the namespace when the class emits
        # them.
        def assert_helper_names_free(plans)
          coerced = plans.select { |_name, plan| plan }.map(&:first)
          names = SLOT_HELPERS.values
          interpreter =
            plans.any? do |_name, plan|
              plan && INTERPRETER_KINDS.include?(plan[0])
            end
          names << "spec" if interpreter || catch_all_spec
          names << "extra" if catch_all_spec
          clash = coerced & names
          return if clash.empty?

          raise CoercionHelperCollisionError,
                "#{@path}: properties #{clash.inspect} would override " \
                  "generated coercion helpers; rename them in the schema"
        end

        # The plan of one property: a spec tree when a coercing format
        # appears anywhere in the slot's structure, the legacy
        # class-shaped plan otherwise, so output for format-free
        # schemas stays exactly as it has always been.
        def coercion_plan(path, name, schema)
          return nil if schema.nil?
          return conversion_spec(path, name, schema) if format_coerced?(schema)

          shaped_plan(path, name, schema)
        end

        # The first class-shaped term of the schema, mirroring the
        # type algebra's approximations (a union of distinct refs
        # keeps the first one; map-shaped objects coerce as maps, not
        # classes). Order: the ref, then an object-typed class, then
        # the variant branches in document order.
        def shaped_plan(path, name, schema)
          if schema.map_shaped?
            value =
              class_term(
                nested_locator(path, name),
                "additionalProperties",
                schema.additional_properties,
              )
            return :map_of, value unless value.nil?

            return nil
          end

          own = class_term(path, name, schema)
          return :class, own unless own.nil?

          element = element_class_term(path, name, schema)
          return :array_of, element unless element.nil?

          nil
        end

        # The conversion spec of a schema node, mirroring bare_type's
        # walk term by term: map-shaped nodes convert their values,
        # own type terms claim through the node's format, the ref and
        # object terms convert as classes, arrays convert elementwise
        # (tuples positionally), and the variant branches join as a
        # union. nil when the node has nothing to convert.
        def conversion_spec(path, name, schema)
          return nil if schema.nil?
          return nil if schema.untyped?

          if schema.map_shaped?
            value =
              conversion_spec(
                nested_locator(path, name),
                "additionalProperties",
                schema.additional_properties,
              )
            return value.nil? ? nil : [:map, value]
          end

          subs = []
          schema.type.each do |type|
            case type
            when TYPE_OBJECT
              subs << [:class, class_name_from_path(path, name)]
            when TYPE_ARRAY
              sub = array_spec(path, name, schema)
              subs << sub unless sub.nil?
            when TYPE_NULL
              # nilability renders through absence; nil rides any
              # coercer's pass-through
            else
              entry = lookup_scalar_type(type, schema.format)
              if entry&.coerces?
                subs << [:coerce, entry.coercer, CLAIM_CLASSES.fetch(type)]
              end
            end
          end
          unless schema.ref.nil?
            subs << [:class, class_name_from_path(schema.ref)]
          end

          # A conjunction's terms are alternative declarations of one
          # value; the first term that converts speaks for the slot.
          return subs.first if schema.intersection

          nested = nested_locator(path, name)
          schema.any_of.each_with_index do |variant, index|
            subs << conversion_spec(nested, "anyOf_#{index}", variant)
          end
          schema.one_of.each_with_index do |variant, index|
            subs << conversion_spec(nested, "oneOf_#{index}", variant)
          end

          combine(subs)
        end

        # The element spec of an array term: prefix positions convert
        # through their own specs, the tail through the items spec,
        # and an open tail passes through.
        def array_spec(path, name, schema)
          nested = nested_locator(path, name)
          prefix =
            schema.prefix_items.filter_map do |item|
              next if item.type.include?(TYPE_BOTTOM)

              conversion_spec(nested, "prefixItems", item)
            end
          tail =
            if schema.items.nil?
              nil
            else
              conversion_spec(nested, "items", schema.items)
            end
          return nil if prefix.empty? && tail.nil?

          element = prefix.empty? ? tail : [:tuple, prefix, tail]
          [:array, element]
        end

        # Folds a node's claiming specs into one: pass-through branches
        # drop out, a single survivor stands alone, two scalar coercers
        # claiming the same JSON class conflict, and the rest compose
        # as a union, structural branches deduplicated in document
        # order (the first class term wins, as everywhere) with the
        # coercers sequenced after them. A variant union folds flat
        # first, so its branches meet the same dedup and conflict
        # rules; sequenced application of the flattened branches is
        # what the interpreter would do with the nesting anyway.
        def combine(subs)
          subs =
            subs.compact.flat_map { |sub| sub[0] == :union ? sub[1] : [sub] }
          return nil if subs.empty?
          return subs.first if subs.size == 1

          structural = []
          coercers = []
          claims = {}
          subs.each do |sub|
            if sub[0] == :coerce
              coercer = sub[1]
              Array(sub[2]).each do |klass|
                other = claims[klass]
                if other && !other.equal?(coercer)
                  raise CoercionConflictError,
                        "#{@path}: #{other} and #{coercer} would both " \
                          "convert #{klass} values in one union; give the " \
                          "branches distinct JSON types or one coercer"
                end
                claims[klass] = coercer
              end
              coercers << [:coerce, coercer, sub[2]]
            else
              claim =
                if sub[0] == :class
                  Hash
                else
                  (sub[0] == :map ? Hash : Array)
                end
              structural << sub unless claims.key?(claim)
              claims[claim] = sub
            end
          end
          coercers.uniq! { |sub| sub[1] }

          subs = structural + coercers
          return nil if subs.empty?
          return subs.first if subs.size == 1

          [:union, subs]
        end

        # Whether a coercing format appears anywhere in the slot's
        # value structure. The catch-all of a non-map node belongs to
        # the class's extra riders, not to this slot.
        def format_coerced?(schema)
          return false if schema.nil?
          return true if scalar_format_coerced?(schema)
          return true if format_coerced?(schema.items)
          if schema.prefix_items&.any? { |item| format_coerced?(item) }
            return true
          end

          if schema.map_shaped? && format_coerced?(schema.additional_properties)
            return true
          end
          if schema.any_of.any? { |variant| format_coerced?(variant) }
            return true
          end

          schema.one_of.any? { |variant| format_coerced?(variant) }
        end

        def scalar_format_coerced?(schema)
          schema.type.any? do |type|
            lookup_scalar_type(type, schema.format)&.coerces?
          end
        end

        # The conversion spec of an open class's extra riders: the
        # catch-all schema's own tree, when it carries a coercing
        # format. A catch-all without one keeps the raw pass-through
        # the class-shaped plans have always had. nil otherwise.
        def catch_all_spec
          return @catch_all_spec if defined?(@catch_all_spec)

          catch_all = @additional_properties
          @catch_all_spec =
            if catch_all.nil? || !format_coerced?(catch_all)
              nil
            else
              conversion_spec(@path, "additionalProperties", catch_all)
            end
        end

        # The first class-shaped term of the schema: the ref, then an
        # object-typed class, then the variant branches in document
        # order. nil when none applies.
        def class_term(path, name, schema)
          return nil if schema.nil?
          return class_name_from_path(schema.ref) unless schema.ref.nil?

          if schema.type.include?(TYPE_OBJECT) && !schema.map_shaped?
            return class_name_from_path(path, name)
          end

          nested = nested_locator(path, name)
          schema.any_of.each_with_index do |variant, index|
            term = class_term(nested, "anyOf_#{index}", variant)
            return term unless term.nil?
          end
          schema.one_of.each_with_index do |variant, index|
            term = class_term(nested, "oneOf_#{index}", variant)
            return term unless term.nil?
          end

          nil
        end

        # The class the array elements coerce through, when the
        # element type carries one: prefix items first (inline object
        # entries have no class and fall through), then items. An
        # open tail (no items) leaves the elements untyped.
        def element_class_term(path, name, schema)
          return nil unless schema.type.include?(TYPE_ARRAY)

          nested = nested_locator(path, name)
          schema.prefix_items.each do |item|
            next if item.type.include?(TYPE_OBJECT) && !item.map_shaped?

            term = class_term(nested, "prefixItems", item)
            return term unless term.nil?
          end

          class_term(nested, "items", schema.items)
        end

        # The class the property's coercion dispatches through,
        # qualified from the output module root so nested module
        # declarations can never shadow it.
        def coercion_class(plan)
          "#{@module_name}::#{plan.last}"
        end

        # The shared coercion machinery, emitted once per class: the
        # slot helpers a legacy plan delegates to, the spec
        # interpreter when a coercing format appears in a property or
        # in the catch-all (the extra delegation runs its subtree
        # through the same interpreter), and the catch-all delegation
        # when the extra riders convert. `sig` prefixes each helper
        # when the output format annotates signatures; the spec
        # interpreter and the catch-all take their own spellings.
        # Classes with no conversions emit nothing.
        def coercion_helpers(sig = nil, spec_sig: sig, leaf_sig: sig)
          parts = []
          if legacy_conversions?
            prefix = sig ? "#{sig}\n" : ""
            parts.concat(helper_bodies.map { |body| "#{prefix}#{body}" })
          end
          if spec_conversions? || catch_all_spec
            if spec_uses_class_slot?
              prefix = sig ? "#{sig}\n" : ""
              parts << "#{prefix}#{class_slot_body}"
            end
            parts << spec_helper_body(spec_sig)
          end
          parts << extra_helper_body(leaf_sig) if catch_all_spec
          return "" if parts.empty?

          parts.join("\n\n")
        end

        # Whether any property converts through a legacy slot helper.
        def legacy_conversions?
          property_coercions.any? do |_name, plan|
            plan && LEGACY_KINDS.include?(plan[0])
          end
        end

        # Whether any property converts through the spec interpreter.
        def spec_conversions?
          property_coercions.any? do |_name, plan|
            plan && INTERPRETER_KINDS.include?(plan[0])
          end
        end

        # Whether a spec tree dispatches through coerce_class_slot,
        # which then has to be emitted next to the interpreter.
        def spec_uses_class_slot?
          specs =
            property_coercions.filter_map do |_name, plan|
              plan if plan && spec_plan?(plan)
            end
          specs << catch_all_spec if catch_all_spec
          specs.any? { |spec| spec_has_class?(spec) }
        end

        def spec_has_class?(spec)
          case spec[0]
          when :class
            true
          when :array
            element = spec[1]
            if element[0] == :tuple
              element[1].any? { |sub| spec_has_class?(sub) } ||
                (element[2] && spec_has_class?(element[2]))
            else
              spec_has_class?(element)
            end
          when :map
            spec_has_class?(spec[1])
          when :union
            spec[1].any? { |sub| spec_has_class?(sub) }
          end
        end

        def helper_bodies
          [class_slot_body, array_slot_body, map_slot_body]
        end

        def class_slot_body
          <<~RUBY.rstrip
            def self.coerce_class_slot(value, klass)
              if value.is_a?(klass)
                value.to_h
              elsif value.is_a?(Hash)
                klass.from_h(value)
              else
                value
              end
            end
          RUBY
        end

        def array_slot_body
          <<~RUBY.rstrip
            def self.coerce_array_slot(value, klass)
              return value unless value.is_a?(Array)

              value.map { |element| coerce_class_slot(element, klass) }
            end
          RUBY
        end

        def map_slot_body
          <<~RUBY.rstrip
            def self.coerce_map_slot(value, klass)
              return value unless value.is_a?(Hash)

              value.transform_values { |entry| coerce_class_slot(entry, klass) }
            end
          RUBY
        end

        # The spec interpreter: one fixed body per class carrying a
        # coercing format, reading the frozen spec literal its
        # delegations pass. The structural branches dispatch on the
        # value's class; the scalar coercers apply in sequence and
        # pass every value they do not own through.
        def spec_helper_body(sig = nil)
          body = <<~RUBY.rstrip
            def self.coerce_spec(value, spec)
              case spec[0]
              when :coerce
                spec[1].coerce(value)
              when :class
                coerce_class_slot(value, spec[1])
              when :array
                return value unless value.is_a?(Array)

                if spec[1][0] == :tuple
                  prefix, tail = spec[1][1], spec[1][2]
                  value.each_with_index.map do |element, index|
                    sub = prefix[index] || tail
                    sub.nil? ? element : coerce_spec(element, sub)
                  end
                else
                  value.map { |element| coerce_spec(element, spec[1]) }
                end
              when :map
                return value unless value.is_a?(Hash)

                value.transform_values { |entry| coerce_spec(entry, spec[1]) }
              when :union
                result = value
                spec[1].each do |sub|
                  case sub[0]
                  when :class
                    result = coerce_class_slot(result, sub[1])
                  when :array
                    if result.is_a?(Array)
                      result =
                        result.map { |element| coerce_spec(element, sub[1]) }
                    end
                  when :map
                    if result.is_a?(Hash)
                      result =
                        result.transform_values do |entry|
                          coerce_spec(entry, sub[1])
                        end
                    end
                  when :coerce
                    result = sub[1].coerce(result)
                  end
                end
                result
              end
            end
          RUBY
          sig ? "#{sig}\n#{body}" : body
        end

        # The delegation of the extra riders to the catch-all spec.
        def extra_helper_body(sig = nil)
          body = <<~RUBY.rstrip
            def self.coerce_extra(value)
              coerce_spec(value, #{spec_literal(catch_all_spec)})
            end
          RUBY
          sig ? "#{sig}\n#{body}" : body
        end

        # The delegation of one property to its slot: scalar leaves
        # call the coercer directly, legacy plans delegate to the
        # shared slot helper, and spec trees run through the
        # interpreter with their literal.
        def coercion_delegation(name, plan)
          case plan[0]
          when :coerce
            <<~RUBY.rstrip
              def self.coerce_#{name}(value)
                #{coercion_target(plan[1])}.coerce(value)
              end
            RUBY
          when :class, :array_of, :map_of
            <<~RUBY.rstrip
              def self.coerce_#{name}(value)
                coerce_#{slot_helper(plan)}(value, #{coercion_class(plan)})
              end
            RUBY
          else
            <<~RUBY.rstrip
              def self.coerce_#{name}(value)
                coerce_spec(value, #{spec_literal(plan)})
              end
            RUBY
          end
        end

        # The constant reference a scalar leaf calls through:
        # built-in coercers resolve top-level under the output module,
        # where every generated file that needs one emits its copy;
        # project coercers are carried by their own name.
        def coercion_target(coercer)
          if Schematrix::Coercers::BUILTIN.include?(coercer)
            return "::#{@module_name}::#{coercer.name}"
          end

          coercer.name
        end

        # The Ruby literal of a spec subtree: symbols, nested arrays,
        # and constant references only, so the generated file holds
        # fixed calls and nothing the table could inject.
        def spec_literal(spec)
          inner =
            case spec[0]
            when :coerce
              coercion_target(spec[1])
            when :class
              "#{@module_name}::#{spec[1]}"
            when :array, :map
              spec_literal(spec[1])
            when :tuple
              "[#{spec[1].map { |sub| spec_literal(sub) }.join(", ")}], " \
                "#{spec[2] ? spec_literal(spec[2]) : "nil"}"
            when :union
              "[#{spec[1].map { |sub| spec_literal(sub) }.join(", ")}]"
            end
          "[:#{spec[0]}, #{inner}]"
        end

        # The built-in coercers this class's conversions call through,
        # in first-use order: the scalar leaves of every property spec
        # and of the catch-all spec.
        def used_builtin_coercers
          specs =
            property_coercions.filter_map do |_name, plan|
              plan if plan && spec_plan?(plan)
            end
          specs << catch_all_spec if catch_all_spec
          coercers = []
          specs.each { |spec| collect_coercers(spec, coercers) }
          coercers
            .select do |coercer|
              Schematrix::Coercers::BUILTIN.include?(coercer)
            end
            .uniq
        end

        def spec_plan?(plan)
          plan[0] != :class && !SLOT_HELPERS.key?(plan[0])
        end

        def collect_coercers(spec, out)
          case spec[0]
          when :coerce
            out << spec[1]
          when :array
            element = spec[1]
            if element[0] == :tuple
              element[1].each { |sub| collect_coercers(sub, out) }
              collect_coercers(element[2], out) if element[2]
            else
              collect_coercers(element, out)
            end
          when :map
            collect_coercers(spec[1], out)
          when :union
            spec[1].each { |sub| collect_coercers(sub, out) }
          end
        end

        # The built-in coercer modules this class uses, emitted once
        # per class after the class body, nested under the output
        # module (where the scalar delegations resolve them), so
        # every file stays self contained like the coercion helpers
        # are. Empty string when no conversion calls a built-in
        # coercer. `sig` prefixes each coerce method where the output
        # annotates signatures, `requires` emits the stdlib load
        # lines executable output needs, and `stub` renders the empty
        # bodies signature files carry.
        def coercer_modules_block(sig: nil, requires: true, stub: false)
          coercers = used_builtin_coercers
          return "" if coercers.empty?

          bodies =
            coercers
              .map do |coercer|
                coercer_module_body(coercer, sig:, requires:, stub:)
              end
              .join("\n\n")
          block = [
            "module Schematrix",
            "  module Coercers",
            indented(bodies, 2),
            "  end",
            "end",
          ].join("\n")
          indented(block, 1)
        end

        def coercer_module_body(coercer, sig:, requires:, stub:)
          lines = []
          if requires
            lines << "require #{coercer::GENERATED_REQUIRE.inspect}"
            lines << ""
          end
          lines << sig if sig
          lines << coercer_method_body(coercer, stub:)
          <<~RUBY.rstrip
            module #{coercer.name.split("::").last}
            #{indented(lines.join("\n"), 1)}
            end
          RUBY
        end

        def coercer_method_body(coercer, stub:)
          return coercer::GENERATED_BODY.rstrip unless stub

          "#{coercer::GENERATED_BODY.lines.first.strip}; end"
        end

        # The helper implementing a plan's slot shape.
        def slot_helper(plan) = SLOT_HELPERS.fetch(plan.first)

        def indented(code, levels)
          code
            .lines
            .map { |line| line == "\n" ? line : ("  " * levels) + line }
            .join
        end
      end
    end
  end
end
