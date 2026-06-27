module Schematrix
  module Output
    # Maps JSON Schema scalar types to their RBS equivalents
    SORBET_SCALAR_TYPES = {
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

        return base if schema.required

        "T.nilable(#{base})"
      end
    end
  end
end
