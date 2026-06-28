# typed: strict

module M
  class RefSibling
    sig { params(anchor: T.nilable(String)).void }
    def initialize(anchor: "myAnchor")
    end

    sig { returns(T.nilable(String)) }
    def anchor
    end

    sig { params(anchor: T.nilable(String)).void }
    def anchor=(anchor)
    end
  end
end
