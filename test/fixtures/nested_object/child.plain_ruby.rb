module M
  class Schema::Child
    def initialize(value: nil)
      @value = value

      @_extra = {}
    end

    attr_accessor :value

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
