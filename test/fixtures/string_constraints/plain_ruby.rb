module M
  class Schema
    def initialize(code: nil)
      @code = code
    end

    attr_accessor :code
  end
end
