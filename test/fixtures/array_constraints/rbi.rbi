# typed: strict

module M
  class Schema
    sig { params(tags: T.anything).void }
    def initialize(tags: nil)
    end

    sig { returns(T.anything) }
    def tags
    end

    sig { params(tags: T.anything).void }
    def tags=(tags)
    end
  end
end
