module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "status" => :status }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def status(value)
        dsl_fields["status"] = (
          if value.is_a?(::M::Schema::Props::Status)
            ::M::Schema::Props::Status.coerce(value)
          else
            value
          end
        )
        self
      end

      def to_h
        dsl_fields.dup
      end

      private

      def dsl_fields
        @dsl_fields ||= {}
      end

      class Builder
        include ::M::Dsl::Schema
      end
    end
  end
end
