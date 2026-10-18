module M
  class Schema
    def initialize(scores: nil)
      @scores = scores

      @_extra = {}
    end

    attr_accessor :scores

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
