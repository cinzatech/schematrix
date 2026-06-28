# typed: strict

module M
  class AllOfRefs
    sig { params(name: String, age: T.nilable(Integer)).void }
    def initialize(name:, age: nil)
      @name = name
      @age = age
    end

    sig { returns(String) }
    attr_accessor :name

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age
  end
end
