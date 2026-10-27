module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "lastName" => :last_name,
      "age" => :age,
      "color" => :color
    }.freeze

    def initialize(first_name:, last_name:, age: nil, color: "blue", _extra: {})
      @first_name = first_name
      @last_name = last_name
      @age = age
      @color = color
      @_extra = _extra.freeze
      freeze
    end

    attr_reader :first_name, :last_name, :age, :color

    def [](key)
      @_extra[key]
    end

    def with(
      first_name: @first_name,
      last_name: @last_name,
      age: @age,
      color: @color,
      _extra: @_extra
    )
      self.class.new(
        first_name: first_name,
        last_name: last_name,
        age: age,
        color: color,
        _extra: _extra
      )
    end

    def ==(other)
      other.is_a?(self.class) && other.first_name == @first_name &&
        other.last_name == @last_name && other.age == @age &&
        other.color == @color && other._extra == @_extra
    end

    alias eql? ==

    def hash
      [self.class, @first_name, @last_name, @age, @color, @_extra].hash
    end

    def self.from_h(hash)
      kwargs = {}
      kwargs[:first_name] = hash["firstName"]
      kwargs[:last_name] = hash["lastName"]
      kwargs[:age] = hash["age"]
      kwargs[:color] = hash["color"] if hash.key?("color")
      kwargs[:_extra] = hash.each_with_object({}) do |(key, value), extras|
        next if ORIGINAL_KEYS.key?(key)
        extras[key] = value
      end
      new(**kwargs)
    end

    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      result["lastName"] = @last_name unless @last_name.nil?
      result["age"] = @age unless @age.nil?
      result["color"] = @color unless @color.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end

    protected

    attr_reader :_extra
  end
end
