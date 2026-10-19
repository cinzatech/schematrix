# typed: strict

module M
  class Schema
    sig { params(owner: T.nilable(Schema::Defs::Named)).void }
    def initialize(owner: nil)
      @owner = owner

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Defs::Named)) }
    attr_accessor :owner

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
