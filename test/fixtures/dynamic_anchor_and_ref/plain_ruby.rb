module M
  class Schema
    def initialize(value: nil, children: nil)
      @value = value
      @children = children

      @_extra = {}
    end

    attr_accessor :value, :children

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
