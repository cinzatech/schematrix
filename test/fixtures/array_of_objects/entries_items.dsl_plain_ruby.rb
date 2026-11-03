module M
  module Dsl
    module Schema
      module Props
        module Entries
          module Items
            ORIGINAL_KEYS = { "name" => :name }.freeze

            def self.build(&block)
              builder = Builder.new
              builder.instance_exec(&block)
              builder.to_h
            end

            def name(value)
              dsl_fields["name"] = value
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
              include ::M::Dsl::Schema::Props::Entries::Items
            end
          end
        end
      end
    end
  end
end
