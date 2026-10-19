# typed: strict

module M
  class Schema
    sig { params(config: T.nilable(T::Hash[String, T.anything])).void }
    def initialize(config: nil)
      @config = config

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(T::Hash[String, T.anything])) }
    attr_accessor :config

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
