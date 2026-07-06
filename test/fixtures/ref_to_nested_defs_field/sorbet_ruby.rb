# typed: strict

module M
  class Schema
    sig { params(items: T.nilable(T::Array[String])).void }
    def initialize(items: nil)
      @items = items
    end

    sig { returns(T.nilable(T::Array[String])) }
    attr_accessor :items
  end
end
