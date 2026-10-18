module M
  class Schema
    def initialize(own: nil, kind: nil)
      @own = own
      @kind = kind

      @_extra = {}
    end

    attr_accessor :own, :kind

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
