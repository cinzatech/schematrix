module M
  class Schema
    def initialize(data: nil)
      @data = data

      @_extra = {}
    end

    attr_accessor :data

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
