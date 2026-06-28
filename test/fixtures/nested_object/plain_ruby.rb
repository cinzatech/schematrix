module M
  class Parent
    def initialize(child: nil)
      @child = child
    end

    attr_accessor :child
  end
end
