# typed: strict

module M
  class WriteOnly
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
    end

    sig { params(value: T.nilable(String)).void }
    def value=(value)
    end
  end
end
