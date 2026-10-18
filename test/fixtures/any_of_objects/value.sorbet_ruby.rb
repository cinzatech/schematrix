# typed: strict

module M
  class Schema::Value
    sig { params(name: T.anything, age: T.anything).void }
    def initialize(name: nil, age: nil)
      @name = name
      @age = age

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.anything) }
    attr_accessor :name

    sig { returns(T.anything) }
    attr_accessor :age

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
