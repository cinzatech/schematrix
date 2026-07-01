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
          base = schema.type.flat_map do |type|
            case type
            when 'object' then [class_name_from_path(path, name)]
            when 'array'  then ["T::Array[#{sorbet_type(@path, 'items', schema.items)}]"]
            when 'null'   then []
            else [SORBET_SCALAR_TYPES.fetch(type, SORBET_TYPE_ANYTHING)]
            end
          end

          combined = combine_types(base)
          return combined if combined == SORBET_TYPE_ANYTHING
          return combined if strictly_required?(schema)

          "T.nilable(#{combined})"
        end

        def combine_types(types)
          return SORBET_TYPE_ANYTHING if types.empty?
          return SORBET_TYPE_ANYTHING if types.include?(SORBET_TYPE_ANYTHING)

          return types.first if types.size == 1

          "T.any(#{types.join(', ')})"
        end

        def sorbet_additional_properties_type
          @sorbet_additional_properties_type ||= sorbet_type(
            @path,
            'additional_properties',
            @additional_properties
          )
        end

        def sorbet_constructor_signature_params
          return '' if @properties.nil?

          @properties.map do |name, property|
            "#{name}: #{sorbet_type(@path, name, property)}"
          end.join(', ')
        end

        def sorbet_attr_accessors
          return '' if @properties.nil?

          @properties.map { |name, property| sorbet_attr_accessor(@path, name, property) }.join("\n\n")
        end

        def sorbet_attr_accessor(path, name, property)
          raise NotImplementedError, "#{self.class} must implement #sorbet_attr_accessor"
        end
      end
    end
  end
end
