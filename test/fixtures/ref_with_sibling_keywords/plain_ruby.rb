module M
  class Schema
    def initialize(anchor: "myAnchor")
      @anchor = anchor
    end

    attr_accessor :anchor
  end
end
