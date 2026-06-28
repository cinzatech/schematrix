# typed: strict

module M
  class Deprecated
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
    end

    # @deprecated
    sig { returns(T.nilable(String)) }
    def value
    end

    # @deprecated
    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end
  end
end
