# typed: strict

module M
  class Schema
    sig { params(data: T.nilable(T::Array[T.any(String, Integer)])).void }
    def initialize(data: nil)
      @data = data

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Array[T.any(String, Integer)])) }
    attr_accessor :data

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
