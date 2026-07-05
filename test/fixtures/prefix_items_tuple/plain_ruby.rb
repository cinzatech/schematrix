module M
  class Schema
    def initialize(point: nil)
      @point = point
    end

    attr_accessor :point
  end
end
