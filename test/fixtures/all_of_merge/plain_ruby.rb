module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "age" => :age }.freeze

    def initialize(name:, age: nil)
      @name = name
      @age = age

      @_extra = {}
    end

    attr_accessor :name, :age

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance = new(name: hash["name"], age: hash["age"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["name"] = @name unless @name.nil?
      result["age"] = @age unless @age.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
