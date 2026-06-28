# typed: strict

module M
  class TupleRest
    sig { params(data: T.anything).void }
    def initialize(data: nil)
    end

    sig { returns(T.anything) }
    def data
    end

    sig { params(data: T.anything).void }
    def data=(data)
    end
  end
end
