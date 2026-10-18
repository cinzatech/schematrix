# typed: strict

module M
  class Schema
    sig { params(anchor: T.nilable(String)).void }
    def initialize(anchor: "myAnchor")
    end

    sig { returns(T.nilable(String)) }
    def anchor
    end

    sig { params(anchor: T.nilable(String)).void }
    def anchor=(anchor)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
