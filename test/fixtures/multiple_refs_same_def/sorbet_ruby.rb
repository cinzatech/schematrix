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
    end

    sig { returns(T.nilable(Schema::Address)) }
    attr_accessor :home

    sig { returns(T.nilable(Schema::Address)) }
    attr_accessor :work
  end
end
