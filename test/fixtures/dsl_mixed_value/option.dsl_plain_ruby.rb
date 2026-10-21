module M
  module Dsl
    class Schema
      module Props
        class Option
          ORIGINAL_KEYS = { "foo" => :foo }.freeze

          def self.build(&block)
            builder = new
            yield builder
            builder.to_h
          end

          def initialize
            @fields = {}
          end

          def foo(value)
            @fields["foo"] = value
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
