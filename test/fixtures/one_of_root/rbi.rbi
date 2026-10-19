# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "foo" => :foo, "bar" => :bar }.freeze

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

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end
end
