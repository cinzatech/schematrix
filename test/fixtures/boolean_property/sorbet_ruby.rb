# typed: strict

module M
  class BooleanProp
    sig { params(value: T.nilable(T::Boolean)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :value
  end
end
