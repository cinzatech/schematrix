# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(Schema::Tags)).void }
    def initialize(tags: nil)
    end

    sig { returns(T.nilable(Schema::Tags)) }
    def tags
    end

    sig { params(tags: T.nilable(Schema::Tags)).void }
    def tags=(tags)
    end
  end
end
