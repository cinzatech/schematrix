# typed: strict

module M
  class ObjOrBool
    sig { params(meta: T.anything).void }
    def initialize(meta: nil)
    end

    sig { returns(T.anything) }
    def meta
    end

    sig { params(meta: T.anything).void }
    def meta=(meta)
    end
  end
end
