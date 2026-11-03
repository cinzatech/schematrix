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
            params(block: T.proc.params(arg0: Child).void).returns(
              T::Hash[String, T.untyped]
            )
          end
          def self.build(&block)
            builder = Builder.new
            yield builder
            builder.to_h
          end

          sig { params(value: String).returns(T.self_type) }
          def value(value)
            dsl_fields["value"] = value
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
            include Child
          end
        end
      end
    end
  end
end
