# typed: strict

module M
  class IntegerProp
    sig { params(value: T.nilable(Integer)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(Integer)) }
    def value
    end

    sig { params(value: T.nilable(Integer)).void }
    def value=(value)
    end
  end
end
