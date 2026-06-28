module M
  class FlatObject
    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active
    end

    attr_accessor :name, :age, :active
  end
end
