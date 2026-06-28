module M
  class NumConstrained
    def initialize(score: nil)
      @score = score
    end

    attr_accessor :score
  end
end
