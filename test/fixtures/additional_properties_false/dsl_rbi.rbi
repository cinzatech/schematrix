# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS = T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.params(arg0: Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
      end

      sig { params(value: String).returns(T.self_type) }
      def name(value)
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
