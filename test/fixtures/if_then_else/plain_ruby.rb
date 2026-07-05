module M
  class Schema
    def initialize(kind: nil, value: nil, tier: nil, reason: nil)
      @kind = kind
      @value = value
      @tier = tier
      @reason = reason
    end

    attr_accessor :kind, :value, :tier, :reason
  end
end
