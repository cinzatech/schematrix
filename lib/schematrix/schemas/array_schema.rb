require_relative 'abstract_schema'

module Schematrix
  module Schemas
    # Schema class for arrays
    class ArraySchema < AbstractSchema
      def initialize(type:, required:, enum:, items:, default:)
        super(type:, required:, enum:, default:)
        @items = items
      end

      attr_reader :items
    end
  end
end
