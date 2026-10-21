# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "kind" => :kind,
          "value" => :value,
          "tier" => :tier,
          "reason" => :reason
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        kind: T.nilable(String),
        value: T.nilable(String),
        tier: T.nilable(Integer),
        reason: T.nilable(String)
      ).void
    end
    def initialize(kind: nil, value: nil, tier: nil, reason: nil)
      @kind = kind
      @value = value
      @tier = tier
      @reason = reason

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :kind

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { returns(T.nilable(Integer)) }
    attr_accessor :tier

    sig { returns(T.nilable(String)) }
    attr_accessor :reason

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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
