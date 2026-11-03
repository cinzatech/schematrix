# typed: strict

module M
  module Dsl
    module Schema
      extend T::Sig

      ORIGINAL_KEYS =
        T.let({ "option" => :option }.freeze, T::Hash[String, Symbol])

      sig do
        params(block: T.proc.params(arg0: Schema).void).returns(
          T::Hash[String, T.untyped]
        )
      end
      def self.build(&block)
        builder = Builder.new
        yield builder
        builder.to_h
      end

      sig do
        params(
          value: T.anything,
          block: T.nilable(T.proc.params(arg0: Schema::Props::Option).void)
        ).returns(T.self_type)
      end
      def option(value = nil, &block)
        if block
          child = M::Dsl::Schema::Props::Option.build(&block)
          current = dsl_fields["option"]
          dsl_fields["option"] = (
            if current.is_a?(Hash)
              current.merge(child)
            else
              child
            end
          )
        else
          dsl_fields["option"] = value
        end
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
        @fields = T.let(@fields, T.nilable(T::Hash[String, T.untyped]))
        @fields ||= {}
      end

      class Builder
        include Schema
      end
    end
  end
end
