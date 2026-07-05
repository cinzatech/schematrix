# typed: strict

module M
  class Schema
    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Schema])
      ).void
    end
    def initialize(value: nil, children: nil)
      @value = value
      @children = children
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { params(children: T.nilable(T::Array[Schema])).void }
    attr_accessor :children
  end
end
