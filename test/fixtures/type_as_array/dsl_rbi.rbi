# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "value" => :value }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.bind(Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
      end

      sig { params(value: T.any(String, Integer)).returns(T.self_type) }
      def value(value)
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
