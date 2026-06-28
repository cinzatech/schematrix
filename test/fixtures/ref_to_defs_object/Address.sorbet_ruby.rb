# typed: strict

module M
  class RefObj::Address
    sig { params(city: T.nilable(String)).void }
    def initialize(city: nil)
      @city = city
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :city
  end
end
