module M
  module Dsl
    class Schema
      module Props
        class Entries
          class Items
            ORIGINAL_KEYS = { "name" => :name }.freeze

            def self.build(&block)
              builder = new
              yield builder
              builder.to_h
            end

            def initialize
              @fields = {}
            end

            def name(value)
              @fields["name"] = value
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
end
