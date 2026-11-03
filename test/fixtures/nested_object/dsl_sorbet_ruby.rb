# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "child" => :child }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.params(arg0: Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
        builder = Builder.new
        yield builder
        builder.to_h
      end

      sig do
        params(block: T.proc.params(arg0: Schema::Props::Child).void).returns(
          T.self_type
        )
      end
      def child(&block)
        child = M::Dsl::Schema::Props::Child.build(&block)
        current = dsl_fields["child"]
        dsl_fields["child"] = current.is_a?(Hash) ? current.merge(child) : child
        self
      end

      sig { params(key: String, value: T.anything).returns(T.self_type) }
      def extra(key, value)
        dsl_fields[key] = value
        self
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
        dsl_fields.dup
      end

      private

      sig { returns(T::Hash[String, T.untyped]) }
      def dsl_fields
        @fields = T.let(@fields, T.nilable(T::Hash[String, T.untyped]))
        @fields ||= {}
      end

      class Builder
        include Schema
      end
    end
  end
end
