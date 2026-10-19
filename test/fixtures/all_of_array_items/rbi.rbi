# typed: strict

module M
  class Schema
    sig { params(values: T.nilable(T::Array[T.all(String, Integer)])).void }
    def initialize(values: nil)
    end

    sig { returns(T.nilable(T::Array[T.all(String, Integer)])) }
    def values
    end

    sig { params(values: T.nilable(T::Array[T.all(String, Integer)])).void }
    def values=(values)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
