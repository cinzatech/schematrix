module M
  class Schema
    def initialize(code: nil)
      @code = code

      @_extra = {}
    end

    attr_accessor :code

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
