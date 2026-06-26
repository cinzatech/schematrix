module Schematrix
  module Schemas
    # Parent class for schema classes
    class AbstractSchema
      def initialize(type:, required:, enum:, default:, description: nil)
        @type = type
        @required = required
        @enum = enum
        @default = default
        @description = description
      end

      attr_reader :type, :required, :enum, :default, :description
    end
  end
end
