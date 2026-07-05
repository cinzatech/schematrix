# typed: strict

module M
  class Schema
    sig { params(anchor: T.nilable(String)).void }
    def initialize(anchor: "myAnchor")
      @anchor = anchor
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :anchor
  end
end
