module M
  class Schema::Value
    def initialize(name: nil, age: nil)
      @name = name
      @age = age

      @_extra = {}
    end

    attr_accessor :name, :age

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
