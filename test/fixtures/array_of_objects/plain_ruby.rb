module M
  class ObjArray
    def initialize(entries: nil)
      @entries = entries
    end

    attr_accessor :entries
  end
end
