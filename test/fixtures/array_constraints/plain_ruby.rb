module M
  class Schema
    def initialize(tags: nil)
      @tags = tags
    end

    attr_accessor :tags
  end
end
