module M
  class MultiRef::Address
    def initialize(city: nil)
      @city = city
    end

    attr_accessor :city
  end
end
