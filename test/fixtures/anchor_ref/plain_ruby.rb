module M
  class Schema
    def initialize(owner: nil)
      @owner = owner

      @_extra = {}
    end

    attr_accessor :owner

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
