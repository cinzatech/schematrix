# typed: strict

module M
  class Recursive
    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Recursive])
      ).void
    end
    def initialize(value: nil, children: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end

    sig { returns(T.nilable(T::Array[Recursive])) }
    def children
    end

    sig { params(children: T.nilable(T::Array[Recursive])).void }
    def children=(children)
    end
  end
end
