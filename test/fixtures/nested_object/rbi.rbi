# typed: strict

module M
  class Parent
    sig { params(child: T.anything).void }
    def initialize(child: nil)
    end

    sig { returns(T.anything) }
    def child
    end

    sig { params(child: T.anything).void }
    def child=(child)
    end
  end
end
