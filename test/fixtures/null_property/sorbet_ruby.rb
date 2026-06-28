# typed: strict

module M
  class NullProp
    sig { params(value: T.nilable(NilClass)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(NilClass)) }
    attr_accessor :value
  end
end
