module M
  module Dsl
    module Schema
      module Props
        module Option
          ORIGINAL_KEYS = { "foo" => :foo }.freeze

          def self.build(&block)
            builder = Builder.new
            yield builder
            builder.to_h
          end

          def foo(value)
            dsl_fields["foo"] = value
            self
          end

          def extra(key, value)
            dsl_fields[key] = value
            self
          end

          def to_h
            dsl_fields.dup
          end

          private

          def dsl_fields
            @fields ||= {}
          end

          class Builder
            include Option
          end
        end
      end
    end
  end
end
