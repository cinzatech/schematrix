module M
  class UntypedEnum
    def initialize(data: nil)
      @data = data
    end

    attr_accessor :data
  end
end
