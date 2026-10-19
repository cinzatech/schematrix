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
    end

    sig { returns(T.nilable(Schema::Props::Home)) }
    def home
    end

    sig { params(home: T.nilable(Schema::Props::Home)).void }
    def home=(home)
    end

    sig { returns(T.nilable(Schema::Defs::Address)) }
    def alt
    end

    sig { params(alt: T.nilable(Schema::Defs::Address)).void }
    def alt=(alt)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
