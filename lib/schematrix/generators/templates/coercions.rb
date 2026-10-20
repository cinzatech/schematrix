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
      module Coercions
        include Resolver

        # The helper a plan's kind delegates to.
        SLOT_HELPERS = {
          class: "class_slot",
          array_of: "array_slot",
          map_of: "map_slot",
        }.freeze

        # The coercion plan of every property, as [mangled name,
        # plan] pairs. A plan is [kind, class name] with kind one of
        # :class, :array_of and :map_of, or nil for properties whose
        # values never need conversion.
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
        # the helper it and its siblings delegate to.
        def assert_helper_names_free(plans)
          coerced = plans.select { |_name, plan| plan }.map(&:first)
          clash = coerced & SLOT_HELPERS.values
          return if clash.empty?

          raise CoercionHelperCollisionError,
                "#{@path}: properties #{clash.inspect} would override " \
                  "generated coercion helpers; rename them in the schema"
        end

        # The first class-shaped term of the schema, mirroring the
        # type algebra's approximations (a union of distinct refs
        # keeps the first one; map-shaped objects coerce as maps, not
        # classes). Order: the ref, then an object-typed class, then
        # the variant branches in document order.
        def coercion_plan(path, name, schema)
          return nil if schema.nil?

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

        # The shared coercion machinery, emitted once per class: one
        # symmetric helper per slot shape. The dispatch reads the
        # value's own class, so the same helper serves loading (Hash
        # in) and dumping (instance in). `sig` prefixes each helper
        # when the output format annotates signatures. Classes with
        # no coerced properties emit nothing.
        def coercion_helpers(sig = nil)
          return "" unless property_coercions.any? { |_name, plan| plan }

          prefix = sig ? "#{sig}\n" : ""
          helper_bodies.map { |body| "#{prefix}#{body}" }.join("\n\n")
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

        # The delegation of one property to its slot's helper.
        def coercion_delegation(name, plan)
          <<~RUBY.rstrip
            def self.coerce_#{name}(value)
              coerce_#{slot_helper(plan)}(value, #{coercion_class(plan)})
            end
          RUBY
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
