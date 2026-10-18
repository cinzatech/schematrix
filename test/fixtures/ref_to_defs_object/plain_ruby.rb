module M
  class Schema
    def initialize(address: nil)
      @address = address

      @_extra = {}
    end

    attr_accessor :address

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
