module M
  class Schema
    def initialize(flag: nil, dead: nil, sibling: nil)
      @flag = flag
      @dead = dead
      @sibling = sibling

      @_extra = {}
    end

    attr_accessor :flag, :dead, :sibling

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
