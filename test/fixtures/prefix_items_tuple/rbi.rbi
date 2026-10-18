# typed: strict

module M
  class Schema
    sig { params(point: T.anything).void }
    def initialize(point: nil)
    end

    sig { returns(T.anything) }
    def point
    end

    sig { params(point: T.anything).void }
    def point=(point)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
