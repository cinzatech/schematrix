module M
  class Schema
    def initialize(items: nil)
      @items = items

      @_extra = {}
    end

    attr_accessor :items

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
