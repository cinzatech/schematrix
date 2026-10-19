# typed: strict

module M
  class Schema
    sig { params(config: T.nilable(Schema::Props::Config)).void }
    def initialize(config: nil)
    end

    sig { returns(T.nilable(Schema::Props::Config)) }
    def config
    end

    sig { params(config: T.nilable(Schema::Props::Config)).void }
    def config=(config)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
