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
    end

    sig { returns(T.nilable(Schema::Address)) }
    def home
    end

    sig { params(home: T.nilable(Schema::Address)).void }
    def home=(home)
    end

    sig { returns(T.nilable(Schema::Address)) }
    def work
    end

    sig { params(work: T.nilable(Schema::Address)).void }
    def work=(work)
    end
  end
end
