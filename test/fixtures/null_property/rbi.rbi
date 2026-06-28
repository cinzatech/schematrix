# typed: strict

module M
  class NullProp
    sig { params(value: T.nilable(NilClass)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(NilClass)) }
    def value
    end

    sig { params(value: T.nilable(NilClass)).void }
    def value=(value)
    end
  end
end
