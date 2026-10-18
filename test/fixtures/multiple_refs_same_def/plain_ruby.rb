module M
  class Schema
    def initialize(home: nil, work: nil)
      @home = home
      @work = work

      @_extra = {}
    end

    attr_accessor :home, :work

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
