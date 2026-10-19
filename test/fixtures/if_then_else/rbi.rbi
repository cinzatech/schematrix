# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "kind" => :kind,
      "value" => :value,
      "tier" => :tier,
      "reason" => :reason
    }.freeze

    sig do
      params(
        kind: T.nilable(String),
        value: T.nilable(String),
        tier: T.nilable(Integer),
        reason: T.nilable(String)
      ).void
    end
    def initialize(kind: nil, value: nil, tier: nil, reason: nil)
    end

    sig { returns(T.nilable(String)) }
    def kind
    end

    sig { params(kind: T.nilable(String)).void }
    def kind=(kind)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end

    sig { returns(T.nilable(Integer)) }
    def tier
    end

    sig { params(tier: T.nilable(Integer)).void }
    def tier=(tier)
    end

    sig { returns(T.nilable(String)) }
    def reason
    end

    sig { params(reason: T.nilable(String)).void }
    def reason=(reason)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
