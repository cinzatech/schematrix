module M
  class StringArray
    def initialize(tags: nil)
      @tags = tags
    end

    attr_accessor :tags
  end
end
