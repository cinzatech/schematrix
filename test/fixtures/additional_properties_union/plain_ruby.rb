module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "code" => :code }.freeze

    def initialize(name: nil, code: nil)
      @name = name
      @code = code

      @_extra = {}
    end

    attr_accessor :name, :code

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(name: hash["name"], code: hash["code"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["code"] = @code unless @code.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
