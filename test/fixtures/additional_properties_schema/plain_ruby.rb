module M
  class Schema
    def initialize(tags: nil)
      @tags = tags

      @_extra = {}
    end

    attr_accessor :tags

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
