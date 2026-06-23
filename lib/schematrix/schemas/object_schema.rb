require_relative 'abstract_schema'

module Schematrix
  module Schemas
    # Schema class for objects
    class ObjectSchema < AbstractSchema
      def initialize(type:, required:, enum:, default:)
        super(type:, required:, enum:, default:)
        @properties = {}
      end

      attr_reader :properties

      def add_property(name, schema)
        @properties[name] = schema
      end
    end
  end
end
