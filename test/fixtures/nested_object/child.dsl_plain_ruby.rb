module M
  module Dsl
    module Schema
      module Props
        module Child
          ORIGINAL_KEYS = { "value" => :value }.freeze

          def self.build(&block)
            builder = Builder.new
            builder.instance_exec(&block)
            builder.to_h
          end

          def value(value)
            dsl_fields["value"] = value
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
            include ::M::Dsl::Schema::Props::Child
          end
        end
      end
    end
  end
end
