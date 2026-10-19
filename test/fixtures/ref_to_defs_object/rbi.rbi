# typed: strict

module M
  class Schema
    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def initialize(address: nil)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def address
    end

    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def address=(address)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
