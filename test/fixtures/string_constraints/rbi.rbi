# typed: strict

module M
  class StringConstrained
    sig { params(code: T.nilable(String)).void }
    def initialize(code: nil)
    end

    sig { returns(T.nilable(String)) }
    def code
    end

    sig { params(code: T.nilable(String)).void }
    def code=(code)
    end
  end
end
