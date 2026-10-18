module M
  class Schema
    def initialize(config: nil)
      @config = config

      @_extra = {}
    end

    attr_accessor :config

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
