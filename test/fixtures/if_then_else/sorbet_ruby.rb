# typed: strict

module M
  class Schema
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

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :kind

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { returns(T.nilable(Integer)) }
    attr_accessor :tier

    sig { returns(T.nilable(String)) }
    attr_accessor :reason

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
