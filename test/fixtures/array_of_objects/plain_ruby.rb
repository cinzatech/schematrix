module M
  class Schema
    def initialize(entries: nil)
      @entries = entries
    end

    attr_accessor :entries
  end
end
