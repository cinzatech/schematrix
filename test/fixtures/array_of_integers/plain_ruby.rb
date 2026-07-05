module M
  class Schema
    def initialize(scores: nil)
      @scores = scores
    end

    attr_accessor :scores
  end
end
