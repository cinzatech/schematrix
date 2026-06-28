module M
  class ConstValue
    def initialize(status: nil)
      @status = status
    end

    attr_accessor :status
  end
end
