# typed: strict

module M
  module Dsl
    module Schema
      module Props
        module Child
          extend T::Sig

          ORIGINAL_KEYS =
            T.let({ "value" => :value }.freeze, T::Hash[String, Symbol])

          sig do
            params(
              block: T.proc.bind(::M::Dsl::Schema::Props::Child).void
            ).returns(T::Hash[String, T.untyped])
          end
          def self.build(&block)
          end

          sig { params(value: String).returns(T.self_type) }
          def value(value)
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
            include ::M::Dsl::Schema::Props::Child
          end
        end
      end
    end
  end
end
