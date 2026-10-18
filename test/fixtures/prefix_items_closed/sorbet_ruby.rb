# typed: strict

module M
  class Schema
    sig { params(point: T.nilable(T::Array[Float])).void }
    def initialize(point: nil)
      @point = point

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Array[Float])) }
    attr_accessor :point

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
