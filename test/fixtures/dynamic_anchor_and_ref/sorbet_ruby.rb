# typed: strict

module M
  class Recursive
    sig { params(value: T.nilable(String), children: T.anything).void }
    def initialize(value: nil, children: nil)
      @value = value
      @children = children
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :value

    sig { returns(T.anything) }
    attr_accessor :children
  end
end
