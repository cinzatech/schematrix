# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS = T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.params(arg0: Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
      end

      sig { void }
      def initialize
      end

      sig { params(value: String).returns(T.self_type) }
      def name(value)
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
      end
    end
  end
end
