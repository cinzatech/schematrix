module M
  class Schema
    def initialize(kind: nil, value: nil, tier: nil, reason: nil)
      @kind = kind
      @value = value
      @tier = tier
      @reason = reason

      @_extra = {}
    end

    attr_accessor :kind, :value, :tier, :reason

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
