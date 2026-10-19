# typed: strict

module M
  class Schema
    sig do
      params(
        home: T.nilable(Schema::Defs::Address),
        work: T.nilable(Schema::Defs::Address)
      ).void
    end
    def initialize(home: nil, work: nil)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def home
    end

    sig { params(home: T.nilable(Schema::Defs::Address)).void }
    def home=(home)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def work
    end

    sig { params(work: T.nilable(Schema::Defs::Address)).void }
    def work=(work)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
