# typed: strict

module M
  class ArrConstrained
    sig { params(tags: T.anything).void }
    def initialize(tags: nil)
      @tags = tags
    end

    sig { returns(T.anything) }
    attr_accessor :tags
  end
end
