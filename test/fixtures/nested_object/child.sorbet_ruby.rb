# typed: strict

module M
  class Schema
    module Props
      class Child
        extend T::Sig

        ORIGINAL_KEYS =
          T.let({ "value" => :value }.freeze, T::Hash[String, Symbol])

        sig { params(value: T.nilable(String)).void }
        def initialize(value: nil)
          @value = value

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :value

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.untyped]).returns(Child) }
        def self.from_h(hash)
          instance = new(value: hash["value"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def to_h
          result = {}
          result["value"] = @value unless @value.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
