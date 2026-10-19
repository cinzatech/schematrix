# typed: strict

module M
  class Schema
    module Defs
      class Address
        ORIGINAL_KEYS = { "city" => :city }.freeze

        sig { params(city: T.nilable(String)).void }
        def initialize(city: nil)
        end

        sig { returns(T.nilable(String)) }
        def city
        end

        sig { params(city: T.nilable(String)).void }
        def city=(city)
        end

        sig { params(key: String).returns(T.anything) }
        def [](key)
        end

        sig { params(key: String, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end

        sig { params(hash: T::Hash[String, T.anything]).returns(Address) }
        def self.from_h(hash)
        end

        sig { returns(T::Hash[String, T.anything]) }
        def to_h
        end
      end
    end
  end
end
