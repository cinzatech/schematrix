# typed: strict

module M
  class AnyOfRef
    sig { params(value: T.anything).void }
    def initialize(value: nil)
    end

    sig { returns(T.anything) }
    def value
    end

    sig { params(value: T.anything).void }
    def value=(value)
    end
  end
end
