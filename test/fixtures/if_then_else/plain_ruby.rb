module M
  class Schema
    ORIGINAL_KEYS = {
      "kind" => :kind,
      "value" => :value,
      "tier" => :tier,
      "reason" => :reason
    }.freeze

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

    def self.from_h(hash)
      instance =
        new(
          kind: hash["kind"],
          value: hash["value"],
          tier: hash["tier"],
          reason: hash["reason"]
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["kind"] = @kind unless @kind.nil?
      result["value"] = @value unless @value.nil?
      result["tier"] = @tier unless @tier.nil?
      result["reason"] = @reason unless @reason.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
