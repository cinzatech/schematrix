# typed: strict

module M
  module Dsl
    module Schema
      module Defs
        module Value
          extend T::Sig

          ORIGINAL_KEYS = T.let({ "v" => :v }.freeze, T::Hash[String, Symbol])

          sig do
            params(block: T.proc.bind(Value).void).returns(
              T::Hash[String, T.untyped]
            )
          end
          def self.build(&block)
          end

          sig { params(value: String).returns(T.self_type) }
          def v(value)
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
            include Value
          end
        end
      end
    end
  end
end
