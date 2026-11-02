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
      # and dump.
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

          if schema.enum_class?
            type = schema.enum.first.is_a?(String) ? TYPE_STRING : TYPE_INTEGER
            if @enums == :classes
              target =
                "::#{@module_name}::#{enum_class_name(path, name, schema)}"
              return :coerce, target, CLAIM_CLASSES.fetch(type)
            end

            entry = lookup_scalar_type(type, schema.format)
            return nil unless entry&.coerces?

            return :coerce, entry.coercer, CLAIM_CLASSES.fetch(type)
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

          combine(subs, uncoerced_claims(schema))
        end

        def uncoerced_claims(schema)
          return CLAIM_CLASSES.values.flatten.uniq if schema.untyped?
          return [] if schema.enum_class? && @enums == :classes

          own =
            schema.type.flat_map do |type|
              entry = lookup_scalar_type(type, schema.format)
              entry&.coerces? ? [] : CLAIM_CLASSES.fetch(type, [])
            end
          own +
            (schema.any_of + schema.one_of).flat_map do |variant|
              uncoerced_claims(variant)
            end
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
            schema.prefix_items.each_with_index.map do |item, index|
              next if item.type.include?(TYPE_BOTTOM)
              next if item.type.include?(TYPE_OBJECT) && !item.map_shaped?

              slot = item.enum_class? ? "prefixItems/#{index}" : "prefixItems"
              conversion_spec(nested, slot, item)
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

        def combine(subs, uncoerced = [])
          subs = flatten_conversion_union(subs)
          enum_claims =
            subs.select { |sub| sub[0] == :coerce && sub[1].is_a?(String) }
          ambiguous =
            enum_claims.select do |sub|
              sub[2].intersect?(uncoerced) ||
                enum_claims.any? do |other|
                  other[1] != sub[1] && sub[2].intersect?(other[2])
                end
            end
          return nil if subs.empty?
          return subs.first if subs.size == 1 && ambiguous.empty?

          structural = []
          coercers = []
          claims = {}
          subs.each do |sub|
            if sub[0] == :coerce
              coercer = sub[1]
              Array(sub[2]).each do |klass|
                other = claims[klass]
                enum_pair = other.is_a?(String) && coercer.is_a?(String)
                if other && other != coercer && !enum_pair
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
              structural << sub unless structural.include?(sub)
              claims[claim] = sub
            end
          end
          coercers.uniq! { |sub| sub[1] }

          structural_claims =
            structural.group_by { |sub| sub[0] == :array ? Array : Hash }
          structural.map! do |sub|
            claim = sub[0] == :array ? Array : Hash
            structural_claims.fetch(claim).size > 1 ? [:try, sub] : sub
          end
          coercers.map! { |sub| ambiguous.include?(sub) ? [:try, sub] : sub }
          subs = structural + coercers
          subs << [:pass] if subs.any? { |sub| sub[0] == :try }
          return nil if subs.empty?
          return subs.first if subs.size == 1

          [:union, subs]
        end

        def flatten_conversion_union(subs)
          subs.compact.flat_map do |sub|
            case sub[0]
            when :union
              flatten_conversion_union(sub[1])
            when :try
              [sub[1]]
            when :pass
              []
            else
              [sub]
            end
          end
        end

        def format_coerced?(schema)
          return false if schema.nil?
          return true if @enums == :classes && schema.enum_class?
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
          return nil if schema.nil? || schema.enum_class?
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
          return coercer if coercer.is_a?(String)

          if Schematrix::Coercers::BUILTIN.include?(coercer)
            return "::#{@module_name}::#{coercer.name}"
          end

          coercer.name
        end

        # The Ruby literal of a spec subtree: symbols, nested arrays,
        # and constant references only, so the generated file holds
        # fixed calls and nothing the table could inject.
        def spec_literal(spec)
          return "[:pass]" if spec[0] == :pass

          inner =
            case spec[0]
            when :coerce
              coercion_target(spec[1])
            when :class
              "#{@module_name}::#{spec[1]}"
            when :array, :map, :try
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
          when :map, :try
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
          # The sig blocks the Sorbet formats annotate the coerce
          # method with only resolve when the module extends T::Sig.
          lines << "extend T::Sig" if sig
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
