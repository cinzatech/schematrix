module M
  class Schema
    def initialize(items: nil)
      @items = items
    end

    attr_accessor :items
  end
end
