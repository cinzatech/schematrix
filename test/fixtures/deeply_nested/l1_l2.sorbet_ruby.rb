# typed: strict

module M
  class Deep::L1::L2
    sig { params(val: T.nilable(String)).void }
    def initialize(val: nil)
      @val = val
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :val
  end
end
