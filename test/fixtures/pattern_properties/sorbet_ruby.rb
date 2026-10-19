# typed: strict

module M
  class Schema
    sig { params(config: T.nilable(Schema::Props::Config)).void }
    def initialize(config: nil)
      @config = config

      @_extra = T.let({}, T::Hash[Symbol, T.anything])
    end

    sig { returns(T.nilable(Schema::Props::Config)) }
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
