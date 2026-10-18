# typed: strict

module M
  class Schema
    sig { params(owner: T.nilable(Schema::Named)).void }
    def initialize(owner: nil)
      @owner = owner

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Named)) }
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
