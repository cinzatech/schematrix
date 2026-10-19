# typed: strict

module M
  class Schema
    sig { params(always: T.nilable(T::Boolean)).void }
    def initialize(always: nil)
    end

    sig { returns(T.nilable(T::Boolean)) }
    def always
    end

    sig { params(always: T.nilable(T::Boolean)).void }
    def always=(always)
    end

    sig do
      params(key: Symbol).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def [](key)
    end

    sig do
      params(
        key: Symbol,
        value: T.nilable(T.any(String, Schema::Defs::Thing))
      ).returns(T.nilable(T.any(String, Schema::Defs::Thing)))
    end
    def []=(key, value)
    end
  end
end
