# typed: strict

module M
  class Recursive
    sig { params(value: T.nilable(String), children: T.anything).void }
    def initialize(value: nil, children: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end

    sig { returns(T.anything) }
    def children
    end

    sig { params(children: T.anything).void }
    def children=(children)
    end
  end
end
