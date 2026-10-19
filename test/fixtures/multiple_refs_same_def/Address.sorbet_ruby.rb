# typed: strict

module M
  class Schema
    module Defs
      class Address
        ORIGINAL_KEYS = { "city" => :city }.freeze

        sig { params(city: T.nilable(String)).void }
        def initialize(city: nil)
          @city = city

          @_extra = T.let({}, T::Hash[String, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :city

        sig { params(key: String).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Address) }
        def self.from_h(hash)
          instance = new(city: hash["city"])

          hash.each do |key, value|
            next if ORIGINAL_KEYS.key?(key)

            instance[key] = value
          end
          instance
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
          result = {}
          result["city"] = @city unless @city.nil?
          @_extra.each { |key, value| result[key] = value }
          result
        end
      end
    end
  end
end
