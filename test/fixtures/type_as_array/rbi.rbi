# typed: strict

module M
  class TypeUnion
    sig { params(value: T.nilable(T.any(String, Integer))).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(T.any(String, Integer))) }
    def value
    end

    sig { params(value: T.nilable(T.any(String, Integer))).void }
    def value=(value)
    end
  end
end
