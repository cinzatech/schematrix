# typed: strict

module M
  class Schema
    sig { params(data: T.nilable(T::Array[T.any(String, Integer)])).void }
    def initialize(data: nil)
    end

    sig { returns(T.nilable(T::Array[T.any(String, Integer)])) }
    def data
    end

    sig { params(data: T.nilable(T::Array[T.any(String, Integer)])).void }
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
