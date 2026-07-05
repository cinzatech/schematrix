# typed: strict

module M
  class Schema
    sig { params(value: T.nilable(T::Boolean)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def value
    end

    sig { params(value: T.nilable(T::Boolean)).void }
    def value=(value)
    end
  end
end
