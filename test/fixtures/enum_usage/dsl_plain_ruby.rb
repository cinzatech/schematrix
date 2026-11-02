module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = { "status" => :status }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def status(value)
        @fields["status"] = (
          if value.is_a?(::M::Schema::Props::Status)
            ::M::Schema::Props::Status.coerce(value)
          else
            value
          end
        )
        self
      end

      def to_h
        @fields.dup
      end
    end
  end
end
