# typed: strict

module M
  class FormatAnnotation
    sig { params(email: T.nilable(String)).void }
    def initialize(email: nil)
      @email = email
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :email
  end
end
