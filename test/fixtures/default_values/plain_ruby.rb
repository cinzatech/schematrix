module M
  class Schema
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count
    end

    attr_accessor :color, :count
  end
end
