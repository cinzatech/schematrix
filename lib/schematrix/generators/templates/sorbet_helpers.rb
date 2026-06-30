module Schematrix
  module Generators
    module Templates
      # Common functions for producing Sorbet output
      module SorbetHelpers
        SORBET_TYPE_ANYTHING = 'T.anything'

        # Maps JSON Schema scalar types to their Sorbet equivalents
        SORBET_SCALAR_TYPES = {
          nil => SORBET_TYPE_ANYTHING,
          TYPE_STRING => 'String',
          TYPE_INTEGER => 'Integer',
          TYPE_NUMBER => 'Float',
          TYPE_BOOLEAN => 'T::Boolean',
          TYPE_NULL => 'NilClass'
        }.freeze

        def sorbet_type(path, name, schema)
          base = case schema
                 when Schemas::ObjectSchema then class_name_from_path(path, name)
                 when Schemas::ArraySchema  then "T::Array[#{sorbet_type(@path, 'items', schema.items)}]"
                 when Schemas::Schema       then scalar_sorbet_type(schema)
                 when nil                   then SORBET_TYPE_ANYTHING
                 else
                   raise "Unknown schema type #{schema.class}"
                 end

          return base if schema&.required || base == SORBET_TYPE_ANYTHING

          "T.nilable(#{base})"
        end

        def scalar_sorbet_type(schema)
          SORBET_SCALAR_TYPES.fetch(schema.type, SORBET_TYPE_ANYTHING)
        end

        def sorbet_additional_properties_type
          @sorbet_additional_properties_type ||= sorbet_type(
            @path,
            'additional_properties',
            @additional_properties
          )
        end

        def sorbet_constructor_signature_params
          @properties.map do |name, property|
            "#{name}: #{sorbet_type(@path, name, property)}"
          end.join(', ')
        end

        def sorbet_attr_accessors
          @properties.map { |name, property| sorbet_attr_accessor(@path, name, property) }.join("\n\n")
        end

        def sorbet_attr_accessor(path, name, property)
          raise NotImplementedError, "#{self.class} must implement #sorbet_attr_accessor"
        end
      end
    end
  end
end
