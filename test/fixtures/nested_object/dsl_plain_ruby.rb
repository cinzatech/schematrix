module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "child" => :child }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def child(&block)
        child = M::Dsl::Schema::Props::Child.build(&block)
        current = @fields["child"]
        @fields["child"] = current.is_a?(Hash) ? current.merge(child) : child
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
