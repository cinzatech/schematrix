module M
  class WriteOnly
    def initialize(value: nil)
      @value = value
    end

    attr_writer :value
  end
end
