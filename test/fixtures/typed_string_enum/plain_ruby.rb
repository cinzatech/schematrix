module M
  class Schema
    def initialize(status: nil)
      @status = status

      @_extra = {}
    end

    attr_accessor :status

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
