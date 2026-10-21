# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "child" => :child }.freeze, T::Hash[String, Symbol])

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

      sig do
        params(block: T.proc.params(arg0: Schema::Props::Child).void).returns(
          T.self_type
        )
      end
      def child(&block)
        child = M::Dsl::Schema::Props::Child.build(&block)
        current = @fields["child"]
        @fields["child"] = current.is_a?(Hash) ? current.merge(child) : child
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
