module M
  class Schema
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
  end
end
