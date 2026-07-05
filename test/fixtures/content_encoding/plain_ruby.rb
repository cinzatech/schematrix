module M
  class Schema
    def initialize(data: nil)
      @data = data
    end

    attr_accessor :data
  end
end
