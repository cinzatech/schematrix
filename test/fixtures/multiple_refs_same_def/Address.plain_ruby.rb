module M
  class Schema::Address
    def initialize(city: nil)
      @city = city

      @_extra = {}
    end

    attr_accessor :city

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
