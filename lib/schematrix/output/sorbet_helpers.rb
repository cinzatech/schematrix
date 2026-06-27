module Schematrix
  module Output
    # Maps JSON Schema scalar types to their Sorbet equivalents
    SORBET_SCALAR_TYPES = {
      nil => 'T.anything',
      TYPE_STRING => 'String',
      TYPE_INTEGER => 'Integer',
      TYPE_NUMBER => 'Float',
      TYPE_BOOLEAN => 'T::Boolean',
      TYPE_NULL => 'NilClass'
    }.freeze

    # Common functions for producing Sorbet output
    module SorbetHelpers
      def sorbet_type(schema)
        base = case schema
               when Schemas::ObjectSchema then 'T.anything'
               when Schemas::ArraySchema  then 'T.anything'
               when Schemas::Schema       then SORBET_SCALAR_TYPES[schema.type]
               else
                 raise "Unknown type #{type}"
               end

        return base if schema.required || base == 'T.anything'

        "T.nilable(#{base})"
      end

      def constructor_signature_params(properties)
        properties.map do |name, property|
          "#{name}: #{sorbet_type(property)}"
        end.join(', ')
      end

      def sorbet_attr_accessors(properties)
        properties.map { |name, property| sorbet_attr_accessor(name, property) }.join("\n\n")
      end

      def sorbet_attr_accessor(name, property)
        raise NotImplementedError, "#{self.class} must implement #sorbet_attr_accessor"
      end
    end
  end
end
