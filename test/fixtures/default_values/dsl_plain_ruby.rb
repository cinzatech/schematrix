module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "color" => :color, "count" => :count }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def color(value)
        @fields["color"] = value
        self
      end

      def count(value)
        @fields["count"] = value
        self
      end

      def extra(key, value)
        @fields[key] = value
        self
      end

      def to_h
        @fields.dup
      end
    end
  end
end
