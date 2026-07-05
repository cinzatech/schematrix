module M
  class Schema::Tags
    def initialize
      @_extra = {}
    end

    attr_accessor

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
