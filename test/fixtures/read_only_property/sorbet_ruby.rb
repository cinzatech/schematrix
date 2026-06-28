# typed: strict

module M
  class ReadOnly
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(String)) }
    attr_reader :value
  end
end
