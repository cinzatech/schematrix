# typed: strict

module M
  class Schema
    sig { params(email: T.nilable(String)).void }
    def initialize(email: nil)
      @email = email

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :email

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
