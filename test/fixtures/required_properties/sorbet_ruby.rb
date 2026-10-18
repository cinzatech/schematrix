# typed: strict

module M
  class Schema
    sig { params(name: String, email: String, age: T.nilable(Integer)).void }
    def initialize(name:, email:, age: nil)
      @name = name
      @email = email
      @age = age

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(String) }
    attr_accessor :name

    sig { returns(String) }
    attr_accessor :email

    sig { returns(T.nilable(Integer)) }
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
