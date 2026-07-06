# typed: strict

module M
  class Schema
    sig { params(items: T.nilable(T::Array[String])).void }
    def initialize(items: nil)
    end

    sig { returns(T.nilable(T::Array[String])) }
    def items
    end

    sig { params(items: T.nilable(T::Array[String])).void }
    def items=(items)
    end
  end
end
