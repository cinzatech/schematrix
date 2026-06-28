module M
  # A described object
  class Described
    def initialize(name: nil)
      @name = name
    end

    attr_accessor :name
  end
end
