# typed: strict

module M
  class WriteOnly
    sig { params(value: T.nilable(String)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { params(value: T.nilable(String)).void }
    attr_writer :value
  end
end
