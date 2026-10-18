# typed: strict

module M
  class Schema
    sig { params(score: T.nilable(Float)).void }
    def initialize(score: nil)
    end

    sig { returns(T.nilable(Float)) }
    def score
    end

    sig { params(score: T.nilable(Float)).void }
    def score=(score)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
