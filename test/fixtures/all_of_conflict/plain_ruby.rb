module M
  class Schema
    def initialize(a: nil)
      @a = a

      @_extra = {}
    end

    attr_accessor :a

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
