# typed: strict

module M
  class Schema
    sig { params(vars: T.nilable(T::Hash[String, Schema::Defs::Value])).void }
    def initialize(vars: nil)
    end

    sig { returns(T.nilable(T::Hash[String, Schema::Defs::Value])) }
    def vars
    end

    sig { params(vars: T.nilable(T::Hash[String, Schema::Defs::Value])).void }
    def vars=(vars)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
