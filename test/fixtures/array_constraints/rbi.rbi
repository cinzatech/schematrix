# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Array[String])).void }
    def initialize(tags: nil)
    end

    sig { returns(T.nilable(T::Array[String])) }
    def tags
    end

    sig { params(tags: T.nilable(T::Array[String])).void }
    def tags=(tags)
    end
  end
end
