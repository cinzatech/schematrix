# typed: strict

module M
  class FlatObject
    sig do
      params(
        name: T.nilable(String),
        age: T.nilable(Integer),
        active: T.nilable(T::Boolean)
      ).void
    end
    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :active
  end
end
