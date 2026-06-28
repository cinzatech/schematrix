module M
  class MapLike
    def initialize(tags: nil)
      @tags = tags
    end

    attr_accessor :tags
  end
end
