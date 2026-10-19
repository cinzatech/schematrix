# typed: strict

module M
  class Schema
    sig do
      params(
        home: T.nilable(Schema::Props::Home),
        alt: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, alt: nil)
      @home = home
      @alt = alt

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Props::Home)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Defs::Address)) }
    attr_accessor :alt

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
