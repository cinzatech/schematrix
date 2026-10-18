module M
  class Schema
    def initialize(name: nil, code: nil)
      @name = name
      @code = code

      @_extra = {}
    end

    attr_accessor :name, :code

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
