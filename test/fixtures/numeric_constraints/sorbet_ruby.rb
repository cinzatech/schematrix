# typed: strict

module M
  class Schema
    sig { params(score: T.nilable(Float)).void }
    def initialize(score: nil)
      @score = score
    end

    sig { returns(T.nilable(Float)) }
    attr_accessor :score
  end
end
