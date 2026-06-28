# typed: strict

module M
  class UntypedArray
    sig { params(data: T.anything).void }
    def initialize(data: nil)
      @data = data
    end

    sig { returns(T.anything) }
    attr_accessor :data
  end
end
