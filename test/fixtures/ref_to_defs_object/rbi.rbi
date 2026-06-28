# typed: strict

module M
  class RefObj
    sig { params(address: T.anything).void }
    def initialize(address: nil)
    end

    sig { returns(T.anything) }
    def address
    end

    sig { params(address: T.anything).void }
    def address=(address)
    end
  end
end
