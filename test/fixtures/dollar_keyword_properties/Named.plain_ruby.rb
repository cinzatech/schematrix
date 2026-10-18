module M
  class Schema::Named
    def initialize(tag: nil)
      @tag = tag

      @_extra = {}
    end

    attr_accessor :tag

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
