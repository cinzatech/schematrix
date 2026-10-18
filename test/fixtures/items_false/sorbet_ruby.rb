# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(T::Array[T.nilable(T.noreturn)])).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.nilable(T::Array[T.nilable(T.noreturn)])) }
    attr_accessor :tags
  end
end
