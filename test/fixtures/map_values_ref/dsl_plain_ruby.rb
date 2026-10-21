module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "vars" => :vars }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def vars(key, &block)
        target = (@fields["vars"] ||= {})
        target[key] = M::Dsl::Schema::Defs::Value.build(&block)
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
