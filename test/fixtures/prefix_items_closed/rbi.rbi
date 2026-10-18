# typed: strict

module M
  class Schema
    sig { params(point: T.nilable(T::Array[Float])).void }
    def initialize(point: nil)
    end

    sig { returns(T.nilable(T::Array[Float])) }
    def point
    end

    sig { params(point: T.nilable(T::Array[Float])).void }
    def point=(point)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
