module M
  class Schema
    def initialize(name:, email:, age: nil)
      @name = name
      @email = email
      @age = age

      @_extra = {}
    end

    attr_accessor :name, :email, :age

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
