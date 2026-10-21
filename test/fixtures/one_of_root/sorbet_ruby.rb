# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let({ "foo" => :foo, "bar" => :bar }.freeze, T::Hash[String, Symbol])

    sig { params(foo: T.untyped, bar: T.untyped).void }
    def initialize(foo: nil, bar: nil)
      @foo = foo
      @bar = bar

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.untyped) }
    attr_accessor :foo

    sig { returns(T.untyped) }
    attr_accessor :bar

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance = new(foo: hash["foo"], bar: hash["bar"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["foo"] = @foo unless @foo.nil?
      result["bar"] = @bar unless @bar.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
