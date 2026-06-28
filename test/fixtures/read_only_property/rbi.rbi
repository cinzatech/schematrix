# typed: strict

module M
  class ReadOnly
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end
  end
end
