# typed: strict

module M
  class NullableType
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value
  end
end
