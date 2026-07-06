# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Array[String])).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.nilable(T::Array[String])) }
    attr_accessor :tags
  end
end
