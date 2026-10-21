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
            builder = new
            yield builder
            builder.to_h
          end

          sig { void }
          def initialize
            @fields = T.let({}, T::Hash[String, T.untyped])
          end

          sig { params(value: String).returns(T.self_type) }
          def v(value)
            @fields["v"] = value
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
  end
end
