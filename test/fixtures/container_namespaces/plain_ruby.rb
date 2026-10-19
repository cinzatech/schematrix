module M
  class Schema
    def initialize(home: nil, alt: nil)
      @home = home
      @alt = alt

      @_extra = {}
    end

    attr_accessor :home, :alt

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
