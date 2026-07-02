# typed: strict

module M
  class NullProp
    sig { params(value: NilClass).void }
    def initialize(value: nil)
    end

    sig { returns(NilClass) }
    def value
    end

    sig { params(value: NilClass).void }
    def value=(value)
    end
  end
end
