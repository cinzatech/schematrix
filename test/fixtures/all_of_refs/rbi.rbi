# typed: strict

module M
  class AllOfRefs
    sig { params(name: String, age: T.nilable(Integer)).void }
    def initialize(name:, age: nil)
    end

    sig { returns(String) }
    def name
    end

    sig { params(name: String).void }
    def name=(name)
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { params(age: T.nilable(Integer)).void }
    def age=(age)
    end
  end
end
