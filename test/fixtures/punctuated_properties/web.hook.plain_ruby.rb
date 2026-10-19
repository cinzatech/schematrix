module M
  class Schema::WebHook
    def initialize(url: nil)
      @url = url

      @_extra = {}
    end

    attr_accessor :url

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
