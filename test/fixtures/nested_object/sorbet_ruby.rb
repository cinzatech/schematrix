# typed: strict

module M
  class Parent
    sig { params(child: T.anything).void }
    def initialize(child: nil)
      @child = child
    end

    sig { returns(T.anything) }
    attr_accessor :child
  end
end
