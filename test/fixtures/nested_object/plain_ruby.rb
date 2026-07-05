module M
  class Schema
    def initialize(child: nil)
      @child = child
    end

    attr_accessor :child
  end
end
