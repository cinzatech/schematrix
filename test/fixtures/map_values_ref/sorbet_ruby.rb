# typed: strict

module M
  class Schema
    sig { params(vars: T.nilable(T::Hash[String, Schema::Defs::Value])).void }
    def initialize(vars: nil)
      @vars = vars

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, Schema::Defs::Value])) }
    attr_accessor :vars

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
