# typed: strict

module M
  class Schema
    sig { params(color: T.nilable(String), count: T.nilable(Integer)).void }
    def initialize(color: "blue", count: 0)
    end

    sig { returns(T.nilable(String)) }
    def color
    end

    sig { params(color: T.nilable(String)).void }
    def color=(color)
    end

    sig { returns(T.nilable(Integer)) }
    def count
    end

    sig { params(count: T.nilable(Integer)).void }
    def count=(count)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
