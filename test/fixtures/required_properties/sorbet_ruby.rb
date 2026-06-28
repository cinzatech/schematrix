# typed: strict

module M
  class Required
    sig { params(name: String, email: String, age: T.nilable(Integer)).void }
    def initialize(name:, email:, age: nil)
      @name = name
      @email = email
      @age = age
    end

    sig { returns(String) }
    attr_accessor :name

    sig { returns(String) }
    attr_accessor :email

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age
  end
end
