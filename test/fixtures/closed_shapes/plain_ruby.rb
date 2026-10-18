module M
  class Schema
    def initialize(name: nil)
      @name = name
    end

    attr_accessor :name
  end
end
