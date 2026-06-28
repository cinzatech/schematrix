# typed: strict

module M
  class RefObj::Address
    sig { params(city: T.nilable(String)).void }
    def initialize(city: nil)
    end

    sig { returns(T.nilable(String)) }
    def city
    end

    sig { params(city: T.nilable(String)).void }
    def city=(city)
    end
  end
end
