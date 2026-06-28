# typed: strict

module M
  class Conditional
    sig { params(kind: T.nilable(String), value: T.nilable(String), tier: T.nilable(Integer), reason: T.nilable(String)).void }
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
  end
end
