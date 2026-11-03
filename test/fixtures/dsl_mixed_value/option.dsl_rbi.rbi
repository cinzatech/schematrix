# typed: strict

module M
  module Dsl
    module Schema
      module Props
        module Option
          extend T::Sig

          ORIGINAL_KEYS =
            T.let({ "foo" => :foo }.freeze, T::Hash[String, Symbol])

          sig do
            params(
              block: T.proc.bind(::M::Dsl::Schema::Props::Option).void
            ).returns(T::Hash[String, T.untyped])
          end
          def self.build(&block)
          end

          sig { params(value: Integer).returns(T.self_type) }
          def foo(value)
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
            include ::M::Dsl::Schema::Props::Option
          end
        end
      end
    end
  end
end
