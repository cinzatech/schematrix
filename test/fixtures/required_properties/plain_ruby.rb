module M
  class Required
    def initialize(name:, email:, age: nil)
      @name = name
      @email = email
      @age = age
    end

    attr_accessor :name, :email, :age
  end
end
