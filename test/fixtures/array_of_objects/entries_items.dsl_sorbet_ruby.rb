# typed: strict

module M
  module Dsl
    module Schema
      module Props
        module Entries
          module Items
            extend T::Sig

            ORIGINAL_KEYS =
              T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

            sig do
              params(
                block: T.proc.bind(::M::Dsl::Schema::Props::Entries::Items).void
              ).returns(T::Hash[String, T.untyped])
            end
            def self.build(&block)
              builder = Builder.new
              builder.instance_exec(&block)
              builder.to_h
            end

            sig { params(value: String).returns(T.self_type) }
            def name(value)
              dsl_fields["name"] = value
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
              @dsl_fields ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
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
