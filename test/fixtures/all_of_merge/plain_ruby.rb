module M
  class Schema
    def initialize(name:, age: nil)
      @name = name
      @age = age
    end

    attr_accessor :name, :age
  end
end
