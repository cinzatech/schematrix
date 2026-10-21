# typed: strict

module M
  module Dsl
    class Schema
      module Props
        class Entries
          class Items
            extend T::Sig

            ORIGINAL_KEYS =
              T.let({ "name" => :name }.freeze, T::Hash[String, Symbol])

            sig do
              params(block: T.proc.params(arg0: Items).void).returns(
                T::Hash[String, T.untyped]
              )
            end
            def self.build(&block)
              builder = new
              yield builder
              builder.to_h
            end

            sig { void }
            def initialize
              @fields = T.let({}, T::Hash[String, T.untyped])
            end

            sig { params(value: String).returns(T.self_type) }
            def name(value)
              @fields["name"] = value
              self
            end

            sig { params(key: String, value: T.anything).returns(T.self_type) }
            def extra(key, value)
              @fields[key] = value
              self
            end

            sig { returns(T::Hash[String, T.untyped]) }
            def to_h
              @fields.dup
            end
          end
        end
      end
    end
  end
end
