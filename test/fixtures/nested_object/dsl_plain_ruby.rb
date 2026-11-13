module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "child" => :child }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def child(&block)
        child = block ? M::Dsl::Schema::Props::Child.build(&block) : {}
        current = dsl_fields["child"]
        dsl_fields["child"] = current.is_a?(Hash) ? current.merge(child) : child
        self
      end

      def extra(key, value)
        dsl_fields[key] = value
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
