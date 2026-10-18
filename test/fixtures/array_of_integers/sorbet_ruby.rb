# typed: strict

module M
  class Schema
    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def initialize(scores: nil)
      @scores = scores

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Array[Integer])) }
    attr_accessor :scores

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
