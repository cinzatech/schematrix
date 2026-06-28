# typed: strict

module M
  class FormatAnnotation
    sig { params(email: T.nilable(String)).void }
    def initialize(email: nil)
    end

    sig { returns(T.nilable(String)) }
    def email
    end

    sig { params(email: T.nilable(String)).void }
    def email=(email)
    end
  end
end
