module M
  class Schema
    def initialize(vars: nil)
      @vars = vars

      @_extra = {}
    end

    attr_accessor :vars

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
