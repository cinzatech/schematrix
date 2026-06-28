module M
  class RefObj
    def initialize(address: nil)
      @address = address
    end

    attr_accessor :address
  end
end
