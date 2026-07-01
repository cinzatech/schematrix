# typed: strict

module M
  class Recursive
    sig do
      params(
        value: T.nilable(String),
        children: T.nilable(T::Array[Recursive])
      ).void
    end
    def initialize(value: nil, children: nil)
      @value = value
      @children = children
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { params(children: T.nilable(T::Array[Recursive])).void }
    attr_accessor :children
  end
end
