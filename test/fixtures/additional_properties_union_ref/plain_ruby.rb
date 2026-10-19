module M
  class Schema
    def initialize(always: nil)
      @always = always

      @_extra = {}
    end

    attr_accessor :always

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
