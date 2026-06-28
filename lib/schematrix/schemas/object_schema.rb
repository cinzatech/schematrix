require_relative 'abstract_schema'

module Schematrix
  module Schemas
    # Schema class for objects
    class ObjectSchema < AbstractSchema
      def initialize(additional_properties:, **kwargs)
        super(**kwargs)
        @additional_properties = additional_properties
        @properties = {}
      end

      attr_reader :properties, :additional_properties

      def add_property(name, schema)
        @properties[name] = schema
      end
    end
  end
end
