# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "foo" => :foo, "bar" => :bar }.freeze

    sig { params(foo: T.anything, bar: T.anything).void }
    def initialize(foo: nil, bar: nil)
      @foo = foo
      @bar = bar

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.anything) }
    attr_accessor :foo

    sig { returns(T.anything) }
    attr_accessor :bar

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance = new(foo: hash["foo"], bar: hash["bar"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
      result = {}
      result["foo"] = @foo unless @foo.nil?
      result["bar"] = @bar unless @bar.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
