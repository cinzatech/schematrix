module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name }.freeze

    def initialize(name: nil)
      @name = name
    end

    attr_accessor :name

    def self.from_h(hash)
      new(name: hash["name"])
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result
    end
  end
end
