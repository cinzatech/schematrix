# typed: strict

module M
  class TypedEnum
    sig { params(status: T.nilable(String)).void }
    def initialize(status: nil)
    end

    sig { returns(T.nilable(String)) }
    def status
    end

    sig { params(status: T.nilable(String)).void }
    def status=(status)
    end
  end
end
