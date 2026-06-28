module M
  class RefSibling
    def initialize(anchor: "myAnchor")
      @anchor = anchor
    end

    attr_accessor :anchor
  end
end
