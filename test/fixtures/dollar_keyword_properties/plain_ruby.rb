module M
  class Schema
    def initialize(id: nil, if_: nil, then_: nil, defs: nil, named: nil)
      @id = id
      @if_ = if_
      @then_ = then_
      @defs = defs
      @named = named

      @_extra = {}
    end

    attr_accessor :id, :if_, :then_, :defs, :named

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
