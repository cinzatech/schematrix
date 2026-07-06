# typed: strict

module M
  class Schema
    sig { params(tags: T.nilable(Schema::Tags)).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.nilable(Schema::Tags)) }
    attr_accessor :tags
  end
end
