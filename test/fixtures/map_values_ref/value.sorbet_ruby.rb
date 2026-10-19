# typed: strict

module M
  module Schema
    module Defs
      class Value
        sig { params(v: T.nilable(String)).void }
        def initialize(v: nil)
          @v = v

          @_extra = T.let({}, T::Hash[Symbol, T.anything])
        end

        sig { returns(T.nilable(String)) }
        attr_accessor :v

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
