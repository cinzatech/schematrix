module M
  class Schema
    def initialize(score: nil)
      @score = score

      @_extra = {}
    end

    attr_accessor :score

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
