module M
  class Schema
    def initialize(child: nil)
      @child = child

      @_extra = {}
    end

    attr_accessor :child

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
