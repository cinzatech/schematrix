module M
  class IntArray
    def initialize(scores: nil)
      @scores = scores
    end

    attr_accessor :scores
  end
end
