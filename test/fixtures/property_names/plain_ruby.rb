module M
  class Schema
    def initialize(vocab: nil)
      @vocab = vocab

      @_extra = {}
    end

    attr_accessor :vocab

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
