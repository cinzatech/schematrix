# typed: strict

module M
  class Deprecated
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
      @value = value
    end

    # @deprecated
    sig { returns(T.nilable(String)) }
    attr_accessor :value
  end
end
