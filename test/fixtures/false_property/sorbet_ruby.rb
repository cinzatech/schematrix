# typed: strict

module M
  class Schema
    sig { params(name: T.nilable(String), legacy: T.nilable(T.noreturn)).void }
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(T.noreturn)) }
    attr_accessor :legacy

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
