# typed: strict

module M
  module Dsl
    module Schema
      module Defs
        module Value
          extend T::Sig

          ORIGINAL_KEYS = T.let({ "v" => :v }.freeze, T::Hash[String, Symbol])

          sig do
            params(block: T.proc.params(arg0: Value).void).returns(
              T::Hash[String, T.untyped]
            )
          end
          def self.build(&block)
            builder = Builder.new
            yield builder
            builder.to_h
          end

          sig { params(value: String).returns(T.self_type) }
          def v(value)
            dsl_fields["v"] = value
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
            include Value
          end
        end
      end
    end
  end
end
