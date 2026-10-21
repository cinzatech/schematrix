# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let(
          { "color" => :color, "count" => :count }.freeze,
          T::Hash[String, Symbol]
        )

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
      def color(value)
      end

      sig { params(value: Integer).returns(T.self_type) }
      def count(value)
      end

      sig { params(key: String, value: T.anything).returns(T.self_type) }
      def extra(key, value)
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
      end
    end
  end
end
