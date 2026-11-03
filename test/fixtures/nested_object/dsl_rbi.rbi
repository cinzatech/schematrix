# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "child" => :child }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.bind(Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
      end

      sig do
        params(block: T.proc.bind(Schema::Props::Child).void).returns(
          T.self_type
        )
      end
      def child(&block)
      end

      sig { params(key: String, value: T.anything).returns(T.self_type) }
      def extra(key, value)
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
      end

      private

      sig { returns(T::Hash[String, T.untyped]) }
      def dsl_fields
      end

      class Builder
        include Schema
      end
    end
  end
end
