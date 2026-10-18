module M
  class Schema
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count

      @_extra = {}
    end

    attr_accessor :color, :count

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
