module M
  class Schema
    def initialize(address: nil)
      @address = address
    end

    attr_accessor :address
  end
end
