# typed: strict

module M
  class IntArray
    sig { params(scores: T.anything).void }
    def initialize(scores: nil)
    end

    sig { returns(T.anything) }
    def scores
    end

    sig { params(scores: T.anything).void }
    def scores=(scores)
    end
  end
end
