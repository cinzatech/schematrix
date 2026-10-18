module M
  class Schema
    def initialize(name: nil, legacy: nil)
      @name = name
      @legacy = legacy
    end

    attr_accessor :name, :legacy
  end
end
