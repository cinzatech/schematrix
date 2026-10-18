module M
  class Schema
    def initialize(anchor: "myAnchor")
      @anchor = anchor

      @_extra = {}
    end

    attr_accessor :anchor

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
