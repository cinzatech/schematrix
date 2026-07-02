require_relative 'base'

module Schematrix
  module Generators
    module Templates
      # RBS template class
      class Rbs < Base
        RBS_TYPE_UNTYPED = 'untyped'

        # Maps JSON Schema scalar types to their RBS equivalents
        RBS_SCALAR_TYPES = {
          nil => RBS_TYPE_UNTYPED,
          TYPE_STRING => 'String',
          TYPE_INTEGER => 'Integer',
          TYPE_NUMBER => 'Float',
          TYPE_BOOLEAN => 'bool',
          TYPE_NULL => 'nil'
        }.freeze

        private

        def rbs_attr_accessors
          return '' if @properties.nil?

          @properties.map do |name, prop_schema|
            "attr_accessor #{name}: #{rbs_type(@path, name, prop_schema)}"
          end.join("\n")
        end

        def rbs_initialize_params
          return '' if @properties.nil?

          @properties.map do |name, schema|
            type = rbs_type(@path, name, schema)
            strictly_required?(schema) ? "#{name}: #{type}" : "?#{name}: #{type}"
          end.join(', ')
        end

        # Returns the RBS type string for a given property schema.
        #
        # The type is made nilable (Type?) for optional properties so the
        # attr_accessor accurately reflects that the value may be nil after
        # construction.
        def rbs_type(path, name, schema)
          return RBS_TYPE_UNTYPED if schema.nil?
          return 'nil' if schema.type == Set['null']

          base = schema.type.flat_map do |type|
            case type
            when 'object' then [class_name_from_path(path, name)]
            when 'array'  then ["Array[#{rbs_type(@path, 'items', schema.items)}]"]
            when 'null'   then []
            when nil      then RBS_TYPE_UNTYPED
            else [RBS_SCALAR_TYPES.fetch(type, RBS_TYPE_UNTYPED)]
            end
          end

          combined = combine_types(base)
          return combined if combined == RBS_TYPE_UNTYPED
          return combined if strictly_required?(schema)

          "#{combined}?"
        end

        def combine_types(types)
          return RBS_TYPE_UNTYPED if types.empty?
          return RBS_TYPE_UNTYPED if types.include?(RBS_TYPE_UNTYPED)

          return types.first if types.size == 1

          types.join(' | ')
        end

        def rbs_additional_properties_type
          rbs_type(@path, 'additional_properties', @additional_properties)
        end
      end
    end
  end
end
