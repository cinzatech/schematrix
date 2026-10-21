# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "value" => :value }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.params(arg0: Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      sig { void }
      def initialize
        @fields = T.let({}, T::Hash[String, T.untyped])
      end

      sig { params(value: T.any(String, Integer)).returns(T.self_type) }
      def value(value)
        @fields["value"] = value
        self
      end

      sig { params(key: String, value: T.anything).returns(T.self_type) }
      def extra(key, value)
        @fields[key] = value
        self
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
        @fields.dup
      end
    end
  end
end
