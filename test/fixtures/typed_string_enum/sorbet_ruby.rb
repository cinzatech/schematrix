# typed: strict

module M
  class TypedEnum
    sig { params(status: T.nilable(String)).void }
    def initialize(status: nil)
      @status = status
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :status
  end
end
