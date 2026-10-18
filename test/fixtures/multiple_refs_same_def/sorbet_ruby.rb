# typed: strict

module M
  class Schema
    sig do
      params(
        home: T.nilable(Schema::Address),
        work: T.nilable(Schema::Address)
      ).void
    end
    def initialize(home: nil, work: nil)
      @home = home
      @work = work

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Address)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Address)) }
    attr_accessor :work

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
