# typed: strict

module M
  class Schema
    sig { params(a: T.nilable(T.all(String, Integer))).void }
    def initialize(a: nil)
      @a = a

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T.all(String, Integer))) }
    attr_accessor :a

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
