module M
  class ReadOnly
    def initialize(value: nil)
      @value = value
    end

    attr_reader :value
  end
end
