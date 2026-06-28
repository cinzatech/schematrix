# typed: strict

module M
  class Required
    sig { params(name: String, email: String, age: T.nilable(Integer)).void }
    def initialize(name:, email:, age: nil)
    end

    sig { returns(String) }
    def name
    end

    sig { params(name: String).void }
    def name=(name)
    end

    sig { returns(String) }
    def email
    end

    sig { params(email: String).void }
    def email=(email)
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { params(age: T.nilable(Integer)).void }
    def age=(age)
    end
  end
end
