# typed: strict

module M
  class Deep::L1::L2
    sig { params(val: T.nilable(String)).void }
    def initialize(val: nil)
    end

    sig { returns(T.nilable(String)) }
    def val
    end

    sig { params(val: T.nilable(String)).void }
    def val=(val)
    end
  end
end
