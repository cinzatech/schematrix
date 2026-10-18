# typed: strict

module M
  class Schema
    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def initialize(scores: nil)
    end

    sig { returns(T.nilable(T::Array[Integer])) }
    def scores
    end

    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def scores=(scores)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
