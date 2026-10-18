# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Array[T.anything])).void }
    def initialize(tags: nil)
    end

    sig { returns(T.nilable(T::Array[T.anything])) }
    def tags
    end

    sig { params(tags: T.nilable(T::Array[T.anything])).void }
    def tags=(tags)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
