# typed: strict

module M
  class Schema
    sig { params(value: T.nilable(Float)).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(Float)) }
    attr_accessor :value
  end
end
