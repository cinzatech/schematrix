# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "firstName" => :first_name,
          "lastName" => :last_name,
          "age" => :age,
          "color" => :color
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        first_name: String,
        last_name: String,
        age: T.nilable(Integer),
        color: T.nilable(String),
        _extra: T::Hash[String, T.anything]
      ).void
    end
    def initialize(first_name:, last_name:, age: nil, color: "blue", _extra: {})
      @first_name = first_name
      @last_name = last_name
      @age = age
      @color = color
      @_extra = T.let(_extra.freeze, T::Hash[String, T.anything])
      freeze
    end

    sig { returns(String) }
    attr_reader :first_name

    sig { returns(String) }
    attr_reader :last_name

    sig { returns(T.nilable(Integer)) }
    attr_reader :age

    sig { returns(T.nilable(String)) }
    attr_reader :color

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig do
      params(
        first_name: String,
        last_name: String,
        age: T.nilable(Integer),
        color: T.nilable(String),
        _extra: T::Hash[String, T.anything]
      ).returns(T.self_type)
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

    sig { params(other: T.untyped).returns(T::Boolean) }
    def ==(other)
      other.is_a?(self.class) && other.first_name == @first_name &&
        other.last_name == @last_name && other.age == @age &&
        other.color == @color && other._extra == @_extra
    end

    alias eql? ==

    sig { returns(Integer) }
    def hash
      [self.class, @first_name, @last_name, @age, @color, @_extra].hash
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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

    sig { returns(T::Hash[String, T.anything]) }
    attr_reader :_extra
  end
end
