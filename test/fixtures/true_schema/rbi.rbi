# typed: strict

module M
  class Schema
    sig { params(value: T.anything).void }
    def initialize(value: nil)
    end

    sig { returns(T.anything) }
    def value
    end

    sig { params(value: T.anything).void }
    def value=(value)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
