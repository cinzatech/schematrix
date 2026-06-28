# typed: strict

module M
  class AnyOfRef
    sig { params(value: T.anything).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.anything) }
    attr_accessor :value
  end
end
