# typed: strict

module M
  class Schema
    sig do
      params(
        flag: T.anything,
        dead: T.nilable(T.noreturn),
        sibling: T.nilable(String)
      ).void
    end
    def initialize(flag: nil, dead: nil, sibling: nil)
    end

    sig { returns(T.anything) }
    def flag
    end

    sig { params(flag: T.anything).void }
    def flag=(flag)
    end

    sig { returns(T.nilable(T.noreturn)) }
    def dead
    end

    sig { params(dead: T.nilable(T.noreturn)).void }
    def dead=(dead)
    end

    sig { returns(T.nilable(String)) }
    def sibling
    end

    sig { params(sibling: T.nilable(String)).void }
    def sibling=(sibling)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
