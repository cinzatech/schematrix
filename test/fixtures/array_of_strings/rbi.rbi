# typed: strict

module M
  class StringArray
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
