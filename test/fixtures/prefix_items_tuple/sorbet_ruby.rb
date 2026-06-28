# typed: strict

module M
  class Tuple
    sig { params(point: T.anything).void }
    def initialize(point: nil)
      @point = point
    end

    sig { returns(T.anything) }
    attr_accessor :point
  end
end
