module M
  class ObjOrBool
    def initialize(meta: nil)
      @meta = meta
    end

    attr_accessor :meta
  end
end
