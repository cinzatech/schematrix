# typed: strict

module M
  class IntegerProp
    sig { params(value: T.nilable(Integer)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(Integer)) }
    attr_accessor :value
  end
end
