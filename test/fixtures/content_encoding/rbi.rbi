# typed: strict

module M
  class Schema
    sig { params(data: T.nilable(String)).void }
    def initialize(data: nil)
    end

    sig { returns(T.nilable(String)) }
    def data
    end

    sig { params(data: T.nilable(String)).void }
    def data=(data)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
