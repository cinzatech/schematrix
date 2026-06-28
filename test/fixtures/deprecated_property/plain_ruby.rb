module M
  class Deprecated
    def initialize(value: nil)
      @value = value
    end

    # @deprecated
    attr_accessor :value
  end
end
