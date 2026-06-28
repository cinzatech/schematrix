# typed: strict

module M
  class AnyOfScalars
    sig { params(value: T.nilable(T.any(String, Integer))).void }
    def initialize(value: nil)
      @value = value
    end

    sig { returns(T.nilable(T.any(String, Integer))) }
    attr_accessor :value
  end
end
