# typed: strict

module M
  class Schema
    sig { params(value: T.nilable(T.any(Schema::Named, String))).void }
    def initialize(value: nil)
    end

    sig { returns(T.nilable(T.any(Schema::Named, String))) }
    def value
    end

    sig { params(value: T.nilable(T.any(Schema::Named, String))).void }
    def value=(value)
    end
  end
end
