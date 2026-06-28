module M
  class Defaults
    def initialize(color: "blue", count: 0)
      @color = color
      @count = count
    end

    attr_accessor :color, :count
  end
end
