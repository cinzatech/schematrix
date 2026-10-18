# typed: strict

module M
  class Schema
    sig { params(a: T.nilable(T.all(String, Integer))).void }
    def initialize(a: nil)
    end

    sig { returns(T.nilable(T.all(String, Integer))) }
    def a
    end

    sig { params(a: T.nilable(T.all(String, Integer))).void }
    def a=(a)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
