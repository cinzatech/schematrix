# typed: strict

module M
  class Conditional
    sig { params(kind: T.nilable(String), value: T.nilable(String), tier: T.nilable(Integer), reason: T.nilable(String)).void }
    def initialize(kind: nil, value: nil, tier: nil, reason: nil)
      @kind = kind
      @value = value
      @tier = tier
      @reason = reason
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :kind

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { returns(T.nilable(Integer)) }
    attr_accessor :tier

    sig { returns(T.nilable(String)) }
    attr_accessor :reason
  end
end
