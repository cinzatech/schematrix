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
    end

    sig { returns(T.nilable(String)) }
    def name
    end

    sig { params(name: T.nilable(String)).void }
    def name=(name)
    end

    sig { returns(T.nilable(Integer)) }
    def age
    end

    sig { params(age: T.nilable(Integer)).void }
    def age=(age)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def active
    end

    sig { params(active: T.nilable(T::Boolean)).void }
    def active=(active)
    end
  end
end
