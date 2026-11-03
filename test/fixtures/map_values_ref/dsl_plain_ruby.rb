module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "vars" => :vars }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def vars(key, &block)
        target = (dsl_fields["vars"] ||= {})
        target[key] = M::Dsl::Schema::Defs::Value.build(&block)
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
