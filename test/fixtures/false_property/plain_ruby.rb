module M
  class Schema
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy

      @_extra = {}
    end

    attr_accessor :name, :legacy

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
