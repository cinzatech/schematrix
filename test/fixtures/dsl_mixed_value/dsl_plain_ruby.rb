module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "option" => :option }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def option(value = nil, &block)
        if block
          child = M::Dsl::Schema::Props::Option.build(&block)
          current = @fields["option"]
          @fields["option"] = current.is_a?(Hash) ? current.merge(child) : child
        else
          @fields["option"] = value
        end
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
