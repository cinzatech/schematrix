# typed: strict

module M
  class Schema::Vocab
    sig { void }
    def initialize
    end

    sig { params(key: Symbol).returns(T::Boolean) }
    def [](key)
    end

    sig { params(key: Symbol, value: T::Boolean).returns(T::Boolean) }
    def []=(key, value)
    end
  end
end
