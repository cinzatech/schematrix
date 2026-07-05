# typed: strict

module M
  class Schema
    sig { params(meta: T.anything).void }
    def initialize(meta: nil)
      @meta = meta
    end

    sig { returns(T.anything) }
    attr_accessor :meta
  end
end
