# typed: strict

module M
  class Parent
    sig { params(child: T.nilable(Parent::Child)).void }
    def initialize(child: nil)
    end

    sig { returns(T.nilable(Parent::Child)) }
    def child
    end

    sig { params(child: T.nilable(Parent::Child)).void }
    def child=(child)
    end
  end
end
