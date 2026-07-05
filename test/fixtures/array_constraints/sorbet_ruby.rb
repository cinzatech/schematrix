# typed: strict

module M
  class Schema
    sig { params(tags: T.anything).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.anything) }
    attr_accessor :tags
  end
end
