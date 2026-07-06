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
  end
end
