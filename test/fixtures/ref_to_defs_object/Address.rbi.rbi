# typed: strict

module M
  module Schema
    module Defs
      class Address
        sig { params(city: T.nilable(String)).void }
        def initialize(city: nil)
        end

        sig { returns(T.nilable(String)) }
        def city
        end

        sig { params(city: T.nilable(String)).void }
        def city=(city)
        end

        sig { params(key: Symbol).returns(T.anything) }
        def [](key)
        end

        sig { params(key: Symbol, value: T.anything).returns(T.anything) }
        def []=(key, value)
        end
      end
    end
  end
end
