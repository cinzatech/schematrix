# typed: strict

module M
  class Schema
    sig { params(foo: T.anything, bar: T.anything).void }
    def initialize(foo: nil, bar: nil)
    end

    sig { returns(T.anything) }
    def foo
    end

    sig { params(foo: T.anything).void }
    def foo=(foo)
    end

    sig { returns(T.anything) }
    def bar
    end

    sig { params(bar: T.anything).void }
    def bar=(bar)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
