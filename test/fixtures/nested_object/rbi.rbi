# typed: strict

module M
  class Schema
    sig { params(child: T.nilable(Schema::Props::Child)).void }
    def initialize(child: nil)
    end

    sig { returns(T.nilable(Schema::Props::Child)) }
    def child
    end

    sig { params(child: T.nilable(Schema::Props::Child)).void }
    def child=(child)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
