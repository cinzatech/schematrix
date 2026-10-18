# typed: strict

module M
  class Schema
    sig { params(code: T.nilable(String)).void }
    def initialize(code: nil)
    end

    sig { returns(T.nilable(String)) }
    def code
    end

    sig { params(code: T.nilable(String)).void }
    def code=(code)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
