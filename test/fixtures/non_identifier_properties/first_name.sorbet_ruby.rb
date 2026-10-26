# typed: strict

module M
  class Schema
    module Props
      class FirstName
        extend T::Sig

        ORIGINAL_KEYS = T.let({ "k" => :k }.freeze, T::Hash[String, Symbol])

        sig { params(k: T.nilable(String)).void }
        def initialize(k: nil)
          @k = k

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :k

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.untyped]).returns(FirstName) }
        def self.from_h(hash)
          instance = new(k: hash["k"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def to_h
          result = {}
          result["k"] = @k unless @k.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
