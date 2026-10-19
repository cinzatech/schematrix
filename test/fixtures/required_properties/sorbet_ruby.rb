# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = { "name" => :name, "email" => :email, "age" => :age }.freeze

    sig { params(name: String, email: String, age: T.nilable(Integer)).void }
    def initialize(name:, email:, age: nil)
      @name = name
      @email = email
      @age = age

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(String) }
    attr_accessor :name

    sig { returns(String) }
    attr_accessor :email

    sig { returns(T.nilable(Integer)) }
    attr_accessor :age

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
      instance = new(name: hash["name"], email: hash["email"], age: hash["age"])

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
      result["email"] = @email unless @email.nil?
      result["age"] = @age unless @age.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
