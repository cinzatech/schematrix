# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Hash[String, String])).void }
    def initialize(tags: nil)
    end

    sig { returns(T.nilable(T::Hash[String, String])) }
    def tags
    end

    sig { params(tags: T.nilable(T::Hash[String, String])).void }
    def tags=(tags)
    end
  end
end
