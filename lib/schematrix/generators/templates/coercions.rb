require_relative "../resolver"

module Schematrix
  module Generators
    module Templates
      # Computes and renders the from_h/to_h round-trip machinery of a
      # generated class (D21). One symmetric class method per property
      # that carries a class-shaped term dispatches on the value's own
      # class: a Hash loads through the target class's from_h, an
      # instance dumps through its to_h, everything else (booleans,
      # scalars, already-raw values) passes through unchanged. D23
      # extends the same rule to plain-Hash map slots (values coerce
      # from the declared catch-all schema) and to array elements.
      module Coercions
        include Resolver

        # The coercion plan of every property, as [mangled name,
        # plan] pairs. A plan is [kind, class name] with kind one of
        # :class, :array_of and :map_of, or nil for properties whose
        # values never need conversion.
        def property_coercions
          @property_coercions ||=
            @properties.to_h.map do |name, schema|
              [name, coercion_plan(@path, "properties/#{name}", schema)]
            end
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

        # The body of one symmetric coercion method. The dispatch
        # reads the value's own class, so the same method serves
        # loading (Hash in) and dumping (instance in); `subject` names
        # the value under dispatch (the element inside arrays, the
        # entry inside maps).
        def coercion_method_body(name, plan)
          klass = coercion_class(plan)
          dispatch =
            lambda do |subject|
              [
                "if #{subject}.is_a?(#{klass})",
                "  #{subject}.to_h",
                "elsif #{subject}.is_a?(Hash)",
                "  #{klass}.from_h(#{subject})",
                "else",
                "  #{subject}",
                "end",
              ].join("\n")
            end

          body =
            case plan.first
            when :class
              dispatch.call("value")
            when :array_of
              [
                "return value unless value.is_a?(Array)",
                "",
                "value.map do |element|",
                indented(dispatch.call("element"), 2),
                "end",
              ].join("\n")
            when :map_of
              [
                "return value unless value.is_a?(Hash)",
                "",
                "value.transform_values do |entry|",
                indented(dispatch.call("entry"), 2),
                "end",
              ].join("\n")
            end

          "def self.coerce_#{name}(value)\n#{indented(body, 1)}\nend"
        end

        # All coercion methods of the class, blank-line separated.
        def coercion_methods
          property_coercions
            .filter_map { |name, plan| coercion_method_body(name, plan) }
            .join("\n\n")
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
