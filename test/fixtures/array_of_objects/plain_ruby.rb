module M
  class Schema
    def initialize(entries: nil)
      @entries = entries

      @_extra = {}
    end

    attr_accessor :entries

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
