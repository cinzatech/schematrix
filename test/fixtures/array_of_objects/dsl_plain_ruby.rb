module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "entries" => :entries }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def entries(&block)
        target = (@fields["entries"] ||= [])
        target << M::Dsl::Schema::Props::Entries::Items.build(&block)
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
