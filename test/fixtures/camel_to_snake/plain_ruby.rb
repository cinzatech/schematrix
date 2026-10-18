module M
  class Schema
    def initialize(first_name: nil, last_name: nil)
      @first_name = first_name
      @last_name = last_name

      @_extra = {}
    end

    attr_accessor :first_name, :last_name

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end
  end
end
