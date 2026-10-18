# typed: strict

module M
  class Schema
    sig { params(email: T.nilable(String)).void }
    def initialize(email: nil)
    end

    sig { returns(T.nilable(String)) }
    def email
    end

    sig { params(email: T.nilable(String)).void }
    def email=(email)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
