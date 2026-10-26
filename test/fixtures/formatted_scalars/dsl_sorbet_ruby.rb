# typed: strict

module M
  module Dsl
    class Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let(
          {
            "created_at" => :created_at,
            "birthday" => :birthday,
            "email" => :email,
            "count" => :count
          }.freeze,
          T::Hash[String, Symbol]
        )

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

      sig { params(value: Time).returns(T.self_type) }
      def created_at(value)
        @fields["created_at"] = value
        self
      end

      sig { params(value: Date).returns(T.self_type) }
      def birthday(value)
        @fields["birthday"] = value
        self
      end

      sig { params(value: String).returns(T.self_type) }
      def email(value)
        @fields["email"] = value
        self
      end

      sig { params(value: Integer).returns(T.self_type) }
      def count(value)
        @fields["count"] = value
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
