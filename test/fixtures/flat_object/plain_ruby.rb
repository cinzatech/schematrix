module M
  class Schema
    ORIGINAL_KEYS = {
      "name" => :name,
      "age" => :age,
      "active" => :active
    }.freeze

    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active

      @_extra = {}
    end

    attr_accessor :name, :age, :active

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.from_h(hash)
      instance =
        new(name: hash["name"], age: hash["age"], active: hash["active"])

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
      result["active"] = @active unless @active.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
