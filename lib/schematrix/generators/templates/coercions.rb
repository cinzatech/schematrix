require_relative "../resolver"

module Schematrix
  module Generators
    module Templates
      # Computes and renders the from_h/to_h round-trip machinery of
      # a generated class. Every conversion is a frozen literal
      # mirroring the type algebra of its slot (scalar leaves,
      # arrays, maps, tuples, unions, classes); the literals travel
      # with the per-property delegations, and the interpreter and
      # the class-slot dispatcher they run through live in the
      # shared CoercionHelper module the coercion_helper generator
      # writes once per output directory. A literal carrying a
      # coercing scalar format claims its JSON class through a
      # coercer, so every rendered formatted type converts on load
      # and dump. A union whose branches would convert the same JSON
      # type through different coercers cannot be attributed from
      # the value alone and fails the run with CoercionConflictError.
      module Coercions
        include Resolver

        # The JSON value classes a document value has when its schema
        # type claims a coercing entry.
        CLAIM_CLASSES = {
          TYPE_STRING => [String].freeze,
          TYPE_INTEGER => [Integer].freeze,
          TYPE_NUMBER => [Integer, Float].freeze,
          TYPE_BOOLEAN => [TrueClass, FalseClass].freeze,
          TYPE_NULL => [NilClass].freeze,
        }.freeze

        # The conversion literal of every property, as [mangled name,
        # literal] pairs: the nested arrays the emitted coerce_spec
        # interpreter reads, or nil for properties whose values never
        # need conversion.
        def property_coercions
          @property_coercions ||= compute_property_coercions
        end

        def compute_property_coercions
          specs =
            @properties.map do |name, schema|
              [name, conversion_spec(@path, "properties/#{name}", schema)]
            end
          assert_helper_names_free(specs)
          specs
        end

        # Property methods and the catch-all delegation share the
        # coerce_ namespace: a property named "extra" would override
        # the catch-all delegation the class emits when its riders
        # convert. The other coercion methods moved to the shared
        # helper module, where no property name can reach them.
        def assert_helper_names_free(specs)
          coerced = specs.select { |_name, literal| literal }.map(&:first)
          names = []
          names << "extra" if catch_all_spec
          clash = coerced & names
          return if clash.empty?

          raise CoercionHelperCollisionError,
                "#{@path}: properties #{clash.inspect} would override " \
                  "generated coercion helpers; rename them in the schema"
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
        # through their own specs (inline object entries have no class
        # and convert through nothing, like the type algebra), the
        # tail through the items spec, and an open tail passes
        # through. Positions that convert nothing keep a nil
        # placeholder, so every spec stays at its schema index, and
        # the tuple form is kept whenever the schema declares prefix
        # positions: the tail never reaches a constrained position.
        def array_spec(path, name, schema)
          nested = nested_locator(path, name)
          prefix =
            schema.prefix_items.map do |item|
              next if item.type.include?(TYPE_BOTTOM)
              next if item.type.include?(TYPE_OBJECT) && !item.map_shaped?

              conversion_spec(nested, "prefixItems", item)
            end
          tail =
            if schema.items.nil?
              nil
            else
              conversion_spec(nested, "items", schema.items)
            end
          return nil if prefix.compact.empty? && tail.nil?

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

        # The delegation of the extra riders to the shared coercion
        # helper module: the class's own catch-all literal, read by
        # the module's interpreter. A property named "extra" would
        # override this delegation and fails the collision check
        # above.
        def extra_helper_body(sig = nil)
          body = <<~RUBY.rstrip
            def self.coerce_extra(value)
              ::#{@module_name}::CoercionHelper.coerce_spec(
                value,
                #{spec_literal(catch_all_spec)}
              )
            end
          RUBY
          sig ? "#{sig}\n#{body}" : body
        end

        # Whether the class references the shared coercion helper
        # module: every delegation whose literal is more than a
        # scalar coercer leaf runs through it, and so does the
        # catch-all delegation.
        def uses_coercion_helper?
          literals = property_coercions.filter_map { |_name, literal| literal }
          literals.any? { |literal| literal[0] != :coerce } ||
            !catch_all_spec.nil?
        end

        # The require of the shared coercion helper module, emitted
        # by class files that reference it. The relative path climbs
        # one level per namespace segment of the class.
        def coercion_helper_require
          return "" unless uses_coercion_helper?

          prefix = [".."] * (@class_name.split("::").size - 1)
          path = (prefix + ["coercion_helper"]).join("/")
          "require_relative #{path.inspect}"
        end

        # The delegation of one property: scalar leaves call the
        # coercer directly, every other literal runs through the
        # shared helper module's interpreter.
        def coercion_delegation(name, literal)
          if literal[0] == :coerce
            <<~RUBY.rstrip
              def self.coerce_#{name}(value)
                #{coercion_target(literal[1])}.coerce(value)
              end
            RUBY
          else
            <<~RUBY.rstrip
              def self.coerce_#{name}(value)
                ::#{@module_name}::CoercionHelper.coerce_spec(
                  value,
                  #{spec_literal(literal)}
                )
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
              positions = spec[1].map { |sub| sub ? spec_literal(sub) : "nil" }
              "[#{positions.join(", ")}], " \
                "#{spec[2] ? spec_literal(spec[2]) : "nil"}"
            when :union
              "[#{spec[1].map { |sub| spec_literal(sub) }.join(", ")}]"
            end
          "[:#{spec[0]}, #{inner}]"
        end

        # The built-in coercers this class's conversions call through,
        # in first-use order: the scalar leaves of every property
        # literal and of the catch-all literal.
        def used_builtin_coercers
          literals = property_coercions.filter_map { |_name, literal| literal }
          literals << catch_all_spec if catch_all_spec
          coercers = []
          literals.each { |literal| collect_coercers(literal, coercers) }
          coercers
            .select do |coercer|
              Schematrix::Coercers::BUILTIN.include?(coercer)
            end
            .uniq
        end

        def collect_coercers(spec, out)
          case spec[0]
          when :coerce
            out << spec[1]
          when :array
            element = spec[1]
            if element[0] == :tuple
              element[1].each { |sub| collect_coercers(sub, out) if sub }
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
