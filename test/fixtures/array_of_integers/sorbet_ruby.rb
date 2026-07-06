# typed: strict

module M
  class Schema
    sig { params(scores: T.nilable(T::Array[Integer])).void }
    def initialize(scores: nil)
      @scores = scores
    end

    sig { returns(T.nilable(T::Array[Integer])) }
    attr_accessor :scores
  end
end
