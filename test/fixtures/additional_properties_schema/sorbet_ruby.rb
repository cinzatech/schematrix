# typed: strict

module M
  class MapLike
    sig { params(tags: T.nilable(T::Hash[String, String])).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.nilable(T::Hash[String, String])) }
    attr_accessor :tags
  end
end
