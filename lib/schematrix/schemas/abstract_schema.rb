module Schematrix
  module Schemas
    # Parent class for schema classes
    class AbstractSchema
      def initialize(type:, required:, enum:, default:)
        @type = type
        @required = required
        @enum = enum
        @default = default
      end

      attr_reader :type, :required, :enum, :default
    end
  end
end
