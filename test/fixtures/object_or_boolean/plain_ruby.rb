module M
  class Schema
    def initialize(meta: nil)
      @meta = meta

      @_extra = {}
    end

    attr_accessor :meta

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
