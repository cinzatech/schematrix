# typed: strict

module M
  class NumberProp
    sig { params(value: T.nilable(Float)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(Float)) }
    def value
    end

    sig { params(value: T.nilable(Float)).void }
    def value=(value)
    end
  end
end
