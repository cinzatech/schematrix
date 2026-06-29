# typed: strict

module M
  class MapLike::Tags
    sig { void }
    def initialize
      @_extra = T.let({}, T::Hash[Symbol, String])
    end

    sig { params(key: Symbol).returns(String) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: Symbol, value:).returns(String) }
    def []=(key, value)
      @_extra[key] = value
    end
  end
end
