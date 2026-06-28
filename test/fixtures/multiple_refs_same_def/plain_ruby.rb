module M
  class MultiRef
    def initialize(home: nil, work: nil)
      @home = home
      @work = work
    end

    attr_accessor :home, :work
  end
end
