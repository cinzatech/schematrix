# typed: strict

module M
  class MultiRef
    sig { params(home: T.anything, work: T.anything).void }
    def initialize(home: nil, work: nil)
    end

    sig { returns(T.anything) }
    def home
    end

    sig { params(home: T.anything).void }
    def home=(home)
    end

    sig { returns(T.anything) }
    def work
    end

    sig { params(work: T.anything).void }
    def work=(work)
    end
  end
end
