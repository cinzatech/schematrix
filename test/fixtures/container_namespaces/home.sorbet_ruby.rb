# typed: strict

module M
  class Schema
    module Props
      class Home
        extend T::Sig

        ORIGINAL_KEYS =
          T.let({ "street" => :street }.freeze, T::Hash[String, Symbol])

        sig { params(street: T.nilable(String)).void }
        def initialize(street: nil)
          @street = street

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :street

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.untyped]).returns(Home) }
        def self.from_h(hash)
          instance = new(street: hash["street"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.untyped]) }
        def to_h
          result = {}
          result["street"] = @street unless @street.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
