# typed: strict

module M
  class Schema
    sig { params(owner: T.nilable(Schema::Named)).void }
    def initialize(owner: nil)
    end

    sig { returns(T.nilable(Schema::Named)) }
    def owner
    end

    sig { params(owner: T.nilable(Schema::Named)).void }
    def owner=(owner)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
