module M
  class Schema
    def initialize(values: nil)
      @values = values

      @_extra = {}
    end

    attr_accessor :values

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
