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
  end
end
