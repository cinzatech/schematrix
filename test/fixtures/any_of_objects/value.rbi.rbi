# typed: strict

module M
  class Schema::Value
    sig { params(name: T.anything, age: T.anything).void }
    def initialize(name: nil, age: nil)
    end

    sig { returns(T.anything) }
    def name
    end

    sig { params(name: T.anything).void }
    def name=(name)
    end

    sig { returns(T.anything) }
    def age
    end

    sig { params(age: T.anything).void }
    def age=(age)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
