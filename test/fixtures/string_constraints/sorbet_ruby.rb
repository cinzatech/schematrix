# typed: strict

module M
  class StringConstrained
    sig { params(code: T.nilable(String)).void }
    def initialize(code: nil)
      @code = code
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :code
  end
end
