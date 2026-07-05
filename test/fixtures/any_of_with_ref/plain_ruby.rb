module M
  class Schema
    def initialize(value: nil)
      @value = value
    end

    attr_accessor :value
  end
end
