# typed: strict

module M
  class Schema
    sig { params(entries: T.anything).void }
    def initialize(entries: nil)
    end

    sig { returns(T.anything) }
    def entries
    end

    sig { params(entries: T.anything).void }
    def entries=(entries)
    end
  end
end
