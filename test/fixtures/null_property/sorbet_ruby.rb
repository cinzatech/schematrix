# typed: strict

module M
  class Schema
    sig { params(value: NilClass).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(NilClass) }
    attr_accessor :value
  end
end
