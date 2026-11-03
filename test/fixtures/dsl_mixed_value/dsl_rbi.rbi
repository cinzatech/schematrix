# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "option" => :option }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.bind(::M::Dsl::Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
      end

      sig do
        params(
          value: T.anything,
          block: T.nilable(T.proc.bind(::M::Dsl::Schema::Props::Option).void)
        ).returns(T.self_type)
      end
      def option(value = nil, &block)
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
        include ::M::Dsl::Schema
      end
    end
  end
end
