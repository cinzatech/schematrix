module M
  class Schema
    def initialize(status: nil)
      @status = status
    end

    attr_accessor :status
  end
end
