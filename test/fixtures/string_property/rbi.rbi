# typed: strict

module M
  class StringProp
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(String)) }
    def value
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end
  end
end
