# typed: strict

module M
  class Parent
    sig { params(child: T.nilable(Parent::Child)).void }
    def initialize(child: nil)
      @child = child
    end

    sig { returns(T.nilable(Parent::Child)) }
    attr_accessor :child
  end
end
