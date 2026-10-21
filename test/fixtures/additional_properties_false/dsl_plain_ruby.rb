module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "name" => :name }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def name(value)
        @fields["name"] = value
        self
      end

      def to_h
        @fields.dup
      end
    end
  end
end
