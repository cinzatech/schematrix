# typed: strict

module M
  module Dsl
    module Schema
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
        params(block: T.proc.bind(::M::Dsl::Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      sig { params(value: Time).returns(T.self_type) }
      def created_at(value)
        dsl_fields["created_at"] = value
        self
      end

      sig { params(value: Date).returns(T.self_type) }
      def birthday(value)
        dsl_fields["birthday"] = value
        self
      end

      sig { params(value: String).returns(T.self_type) }
      def email(value)
        dsl_fields["email"] = value
        self
      end

      sig { params(value: Integer).returns(T.self_type) }
      def count(value)
        dsl_fields["count"] = value
        self
      end

      sig { params(key: String, value: T.anything).returns(T.self_type) }
      def extra(key, value)
        dsl_fields[key] = value
        self
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
        dsl_fields.dup
      end

      private

      sig { returns(T::Hash[String, T.untyped]) }
      def dsl_fields
        @dsl_fields ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
      end

      class Builder
        include ::M::Dsl::Schema
      end
    end
  end
end
