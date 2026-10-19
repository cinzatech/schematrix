# typed: strict

module M
  class Schema
    sig { params(address: T.nilable(Schema::Defs::Address)).void }
    def initialize(address: nil)
      @address = address

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :address

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
