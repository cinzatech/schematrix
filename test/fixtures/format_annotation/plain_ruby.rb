module M
  class Schema
    def initialize(email: nil)
      @email = email

      @_extra = {}
    end

    attr_accessor :email

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
