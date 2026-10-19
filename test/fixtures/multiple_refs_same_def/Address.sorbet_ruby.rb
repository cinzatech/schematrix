# typed: strict

module M
  module Schema
    module Defs
      class Address
        sig { params(city: T.nilable(String)).void }
        def initialize(city: nil)
          @city = city

          @_extra = T.let({}, T::Hash[Symbol, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :city

        sig { params(key: Symbol).returns(T.anything) }
        def [](key)
          @_extra[key]
        end

        sig { params(key: Symbol, value: T.anything).returns(T.anything) }
        def []=(key, value)
          @_extra[key] = value
        end
      end
    end
  end
end
