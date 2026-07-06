# typed: strict

module M
  class Schema
    sig { params(data: T.nilable(T::Array[T.anything])).void }
    def initialize(data: nil)
      @data = data
    end

    sig { returns(T.nilable(T::Array[T.anything])) }
    attr_accessor :data
  end
end
