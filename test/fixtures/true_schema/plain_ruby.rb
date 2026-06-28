module M
  class TrueSchema
    def initialize(value: nil)
      @value = value
    end

    attr_accessor :value
  end
end
