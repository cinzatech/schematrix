# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "entries" => :entries }.freeze, T::Hash[String, Symbol])

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
        params(
          block: T.proc.params(arg0: Schema::Props::Entries::Items).void
        ).returns(T.self_type)
      end
      def entries(&block)
        target = (@fields["entries"] ||= [])
        target << M::Dsl::Schema::Props::Entries::Items.build(&block)
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
