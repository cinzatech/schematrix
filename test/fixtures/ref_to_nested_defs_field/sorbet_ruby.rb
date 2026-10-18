# typed: strict

module M
  class Schema
    sig { params(items: T.nilable(T::Array[String])).void }
    def initialize(items: nil)
      @items = items

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Array[String])) }
    attr_accessor :items

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
