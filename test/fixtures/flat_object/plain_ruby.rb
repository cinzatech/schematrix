module M
  class Schema
    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active

      @_extra = {}
    end

    attr_accessor :name, :age, :active

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
