# typed: strict

module M
  class Schema
    sig { params(status: T.nilable(String)).void }
    def initialize(status: nil)
    end

    sig { returns(T.nilable(String)) }
    def status
    end

    sig { params(status: T.nilable(String)).void }
    def status=(status)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
