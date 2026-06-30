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
          @properties.map do |name, prop_schema|
            "attr_accessor #{name}: #{rbs_type(@path, name, prop_schema)}"
          end.join("\n")
        end

        def rbs_initialize_params
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
          base = case schema
                 when Schemas::ObjectSchema then class_name_from_path(path, name)
                 when Schemas::ArraySchema  then "Array[#{rbs_type(@path, 'items', schema.items)}]"
                 when Schemas::Schema       then scalar_rbs_type(schema)
                 else RBS_TYPE_UNTYPED
                 end

          strictly_required?(schema) ? base : "#{base}?"
        end

        def rbs_additional_properties_type
          rbs_type(@path, 'additional_properties', @object)
        end

        # A property is strictly required when it is marked required in the schema
        # AND has no default value. Properties with defaults are optional in the
        # constructor (the PlainRuby generator fills them in), so the RBS
        # signature should match.
        def strictly_required?(schema)
          return false unless schema.respond_to?(:required) && schema.required
          return false if schema.respond_to?(:default) && !schema.default.nil?

          true
        end

        def scalar_rbs_type(schema)
          RBS_SCALAR_TYPES.fetch(schema.type, RBS_TYPE_UNTYPED)
        end
      end
    end
  end
end
