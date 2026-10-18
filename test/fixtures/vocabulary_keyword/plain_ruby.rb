module M
  class Schema
    def initialize(name: nil)
      @name = name

      @_extra = {}
    end

    attr_accessor :name

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
