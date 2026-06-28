# typed: strict

module M
  class ObjArray
    sig { params(entries: T.anything).void }
    def initialize(entries: nil)
      @entries = entries
    end

    sig { returns(T.anything) }
    attr_accessor :entries
  end
end
