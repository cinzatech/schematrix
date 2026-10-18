module Schematrix
  module Generators
    module Templates
      # Common functions for producing Sorbet output
      module SorbetHelpers
        SORBET_TYPE_ANYTHING = "T.anything"

        # Maps JSON Schema scalar types to their Sorbet equivalents
        SORBET_SCALAR_TYPES = {
          nil => SORBET_TYPE_ANYTHING,
          TYPE_STRING => "String",
          TYPE_INTEGER => "Integer",
          TYPE_NUMBER => "Float",
          TYPE_BOOLEAN => "T::Boolean",
          TYPE_NULL => "NilClass",
          TYPE_BOTTOM => "T.noreturn",
        }.freeze

        def sorbet_type(path, name, schema)
          return SORBET_TYPE_ANYTHING if schema.nil?
          return "NilClass" if schema.type == Set["null"]

          combined = bare_sorbet_type(path, name, schema)
          return combined if combined == SORBET_TYPE_ANYTHING
          return combined if strictly_required?(schema)

          "T.nilable(#{combined})"
        end

        # Returns the type for a schema as a union string, without
        # nilability: the declared type set, the $ref target, and both
        # variant lists folded in (D1), each variant a bare type too.
        def bare_sorbet_type(path, name, schema)
          return SORBET_TYPE_ANYTHING if schema.nil?

          base =
            schema.type.flat_map do |type|
              case type
              when "object"
                [class_name_from_path(path, name)]
              when "array"
                items_type =
                  sorbet_type(nested_locator(path, name), "items", schema.items)
                ["T::Array[#{items_type}]"]
              when "null"
                []
              else
                [SORBET_SCALAR_TYPES.fetch(type, SORBET_TYPE_ANYTHING)]
              end
            end

          # TODO: Schemas may combine a $ref and some overrides
          base << class_name_from_path(schema.ref) unless schema.ref.nil?

          base.concat(variant_types(path, name, schema.any_of, "anyOf"))
          base.concat(variant_types(path, name, schema.one_of, "oneOf"))

          combine_types(base)
        end

        # Computes the bare type of each variant branch under its
        # positional path segment (anyOf_0, oneOf_1, ...).
        def variant_types(path, name, variants, keyword)
          variants.each_with_index.map do |variant, index|
            variant_path = nested_locator(path, name)
            bare_sorbet_type(variant_path, "#{keyword}_#{index}", variant)
          end
        end

        def combine_types(types)
          return SORBET_TYPE_ANYTHING if types.empty?
          return SORBET_TYPE_ANYTHING if types.include?(SORBET_TYPE_ANYTHING)

          return types.first if types.size == 1

          "T.any(#{types.join(", ")})"
        end

        def sorbet_additional_properties_type
          @sorbet_additional_properties_type ||=
            sorbet_type(@path, "additional_properties", @additional_properties)
        end

        def sorbet_constructor_signature_params
          return "" if @properties.nil? || @properties.empty?

          params =
            @properties
              .map do |name, property|
                "#{name}: #{sorbet_type(@path, name, property)}"
              end
              .join(", ")

          "params(#{params})."
        end

        def sorbet_attr_accessors
          return "" if @properties.nil?

          @properties
            .map do |name, property|
              sorbet_attr_accessor(@path, name, property)
            end
            .join("\n\n")
        end

        def sorbet_attr_accessor(path, name, property)
          raise NotImplementedError,
                "#{self.class} must implement #sorbet_attr_accessor"
        end
      end
    end
  end
end
