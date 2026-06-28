module M
  class Recursive
    def initialize(value: nil, children: nil)
      @value = value
      @children = children
    end

    attr_accessor :value, :children
  end
end
