module M
  module Dsl
    module Schema
      module Defs
        module Value
          ORIGINAL_KEYS = { "v" => :v }.freeze

          def self.build(&block)
            builder = Builder.new
            builder.instance_exec(&block)
            builder.to_h
          end

          def v(value)
            dsl_fields["v"] = value
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
            include Value
          end
        end
      end
    end
  end
end
