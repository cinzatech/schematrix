require 'syntax_tree/rbs'

require_relative 'base_generator'

module Schematrix
  module Output
    # Outputs RBS type signatures matching a JSON Schema object
    class Rbs < BaseGenerator
      # Maps JSON Schema scalar types to their RBS equivalents
      RBS_SCALAR_TYPES = {
        TYPE_STRING => 'String',
        TYPE_INTEGER => 'Integer',
        TYPE_NUMBER => 'Float',
        TYPE_BOOLEAN => 'bool',
        TYPE_NULL => 'nil'
      }.freeze

      def self.template_name
        'rbs.erb'
      end

      private

      def file_extension
        '.rbs'
      end

      def format_code(code)
        return SyntaxTree::RBS.format(code) if @format

        code
      end

      def rbs_attr_accessors(path, schema)
        schema.properties.map do |name, prop_schema|
          "attr_accessor #{underscore(name)}: #{rbs_type(path, name, prop_schema)}"
        end.join("\n")
      end

      def rbs_initialize_params(path, properties)
        properties.map do |name, schema|
          type = rbs_type(path, name, schema)
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
               when Schemas::ObjectSchema then nested_class_ref(path, name)
               when Schemas::ArraySchema  then array_rbs_type(schema.items)
               when Schemas::Schema       then scalar_rbs_type(schema)
               else 'untyped'
               end

        strictly_required?(schema) ? base : "#{base}?"
      end

      def additional_properties_type(path, schema)
        rbs_type(path, 'additional_properties', schema)
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
        return 'untyped' if schema.type.nil?

        RBS_SCALAR_TYPES.fetch(schema.type, 'untyped')
      end

      # items is the raw JSON hash from the schema (the visitor does not
      # recursively visit array items). Object items ($ref or inline object)
      # fall back to untyped because their class is generated separately and
      # there is no reliable way to derive the reference from here.
      def array_rbs_type(items)
        return 'Array[untyped]' unless items.is_a?(Hash)
        return 'Array[untyped]' if items.key?('$ref')
        return 'Array[untyped]' if items['type'] == TYPE_OBJECT

        item_type = RBS_SCALAR_TYPES.fetch(items['type'], 'untyped')
        "Array[#{item_type}]"
      end
    end
  end
end
