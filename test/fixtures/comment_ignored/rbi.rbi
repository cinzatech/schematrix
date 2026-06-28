# typed: strict

module M
  class CommentIgnored
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end
  end
end
