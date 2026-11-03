# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS = T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.bind(Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      sig { params(value: String).returns(T.self_type) }
      def name(value)
        dsl_fields["name"] = value
        self
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
        dsl_fields.dup
      end

      private

      sig { returns(T::Hash[String, T.untyped]) }
      def dsl_fields
        @fields = T.let(@fields, T.nilable(T::Hash[String, T.untyped]))
        @fields ||= {}
      end

      class Builder
        include Schema
      end
    end
  end
end
