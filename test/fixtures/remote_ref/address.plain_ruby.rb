module M
  class Address
    def initialize(street: nil, zip: nil)
      @street = street
      @zip = zip

      @_extra = {}
    end

    attr_accessor :street, :zip

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
