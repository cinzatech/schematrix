module M
  module Dsl
    class Schema
      module Defs
        class Value
          ORIGINAL_KEYS = { "v" => :v }.freeze

          def self.build(&block)
            builder = new
            yield builder
            builder.to_h
          end

          def initialize
            @fields = {}
          end

          def v(value)
            @fields["v"] = value
            self
          end

          def extra(key, value)
            @fields[key] = value
            self
          end

          def to_h
            @fields.dup
          end
        end
      end
    end
  end
end
