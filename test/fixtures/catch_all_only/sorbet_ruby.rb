# typed: strict

module M
  class Schema
    sig { void }
    def initialize
      @_extra = T.let({}, T::Hash[Symbol, T.nilable(String)])
    end

    sig { params(key: Symbol).returns(T.nilable(String)) }
    def [](key)
      @_extra[key]
    end

    sig do
      params(key: Symbol, value: T.nilable(String)).returns(T.nilable(String))
    end
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
