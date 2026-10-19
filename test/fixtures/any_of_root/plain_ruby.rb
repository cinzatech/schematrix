module M
  class Schema
    ORIGINAL_KEYS = { "foo" => :foo, "bar" => :bar }.freeze

    def initialize(foo: nil, bar: nil)
      @foo = foo
      @bar = bar

      @_extra = {}
    end

    attr_accessor :foo, :bar

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(foo: hash["foo"], bar: hash["bar"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["foo"] = @foo unless @foo.nil?
      result["bar"] = @bar unless @bar.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
