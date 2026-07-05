# typed: strict

module M
  class Schema
    sig { params(items: T.anything).void }
    def initialize(items: nil)
    end

    sig { returns(T.anything) }
    def items
    end

    sig { params(items: T.anything).void }
    def items=(items)
    end
  end
end
