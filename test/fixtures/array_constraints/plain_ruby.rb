module M
  class ArrConstrained
    def initialize(tags: nil)
      @tags = tags
    end

    attr_accessor :tags
  end
end
