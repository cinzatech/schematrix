# typed: strict

module M
  class Schema
    sig { params(child: T.nilable(Schema::Child)).void }
    def initialize(child: nil)
    end

    sig { returns(T.nilable(Schema::Child)) }
    def child
    end

    sig { params(child: T.nilable(Schema::Child)).void }
    def child=(child)
    end
  end
end
