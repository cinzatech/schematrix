module M
  class TypedEnum
    def initialize(status: nil)
      @status = status
    end

    attr_accessor :status
  end
end
