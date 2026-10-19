# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "name" => :name,
      "age" => :age,
      "active" => :active
    }.freeze

    sig do
      params(
        name: T.nilable(String),
        age: T.nilable(Integer),
        active: T.nilable(T::Boolean)
      ).void
    end
    def initialize(name: nil, age: nil, active: nil)
      @name = name
      @age = age
      @active = active

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(T.nilable(String)) }
    attr_accessor :name

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :active

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(name: hash["name"], age: hash["age"], active: hash["active"])

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.anything]) }
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
