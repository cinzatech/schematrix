# typed: strict

module M
  class Schema
    sig { params(foo: T.anything, bar: T.anything).void }
    def initialize(foo: nil, bar: nil)
      @foo = foo
      @bar = bar

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.anything) }
    attr_accessor :foo

    sig { returns(T.anything) }
    attr_accessor :bar

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
