# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(Schema::Props::Tags)).void }
    def initialize(tags: nil)
    end

    sig { returns(T.nilable(Schema::Props::Tags)) }
    def tags
    end

    sig { params(tags: T.nilable(Schema::Props::Tags)).void }
    def tags=(tags)
    end

    sig { params(key: Symbol).returns(T.anything) }
    def [](key)
    end

    sig { params(key: Symbol, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end
  end
end
