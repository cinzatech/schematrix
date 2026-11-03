module M
  module Dsl
    module Schema
      module Props
        module Option
          ORIGINAL_KEYS = { "foo" => :foo }.freeze

          def self.build(&block)
            builder = Builder.new
            builder.instance_exec(&block)
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
            @dsl_fields ||= {}
          end

          class Builder
            include ::M::Dsl::Schema::Props::Option
          end
        end
      end
    end
  end
end
