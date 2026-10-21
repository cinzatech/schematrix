module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "tags" => :tags }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def tags(key, value)
        target = (@fields["tags"] ||= {})
        target[key] = value
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
