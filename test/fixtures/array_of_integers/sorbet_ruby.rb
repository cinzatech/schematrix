# typed: strict

module M
  class Schema
    sig { params(scores: T.anything).void }
    def initialize(scores: nil)
      @scores = scores
    end

    sig { returns(T.anything) }
    attr_accessor :scores
  end
end
