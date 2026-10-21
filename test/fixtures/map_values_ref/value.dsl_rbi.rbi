# typed: strict

module M
  module Dsl
    class Schema
      module Defs
        class Value
          extend T::Sig

          ORIGINAL_KEYS = T.let({ "v" => :v }.freeze, T::Hash[String, Symbol])

          sig do
            params(block: T.proc.params(arg0: Value).void).returns(
              T::Hash[String, T.untyped]
            )
          end
          def self.build(&block)
          end

          sig { void }
          def initialize
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
        end
      end
    end
  end
end
