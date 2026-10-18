# typed: strict

module M
  class Schema
    sig do
      params(
        name: T.nilable(String),
        age: T.nilable(Integer),
        active: T.nilable(T::Boolean)
      ).void
    end
    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :active

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
