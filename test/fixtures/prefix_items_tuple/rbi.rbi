# typed: strict

module M
  class Tuple
    sig { params(point: T.anything).void }
    def initialize(point: nil)
    end

    sig { returns(T.anything) }
    def point
    end

    sig { params(point: T.anything).void }
    def point=(point)
    end
  end
end
