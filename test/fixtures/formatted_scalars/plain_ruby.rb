require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = {
      "created_at" => :created_at,
      "birthday" => :birthday,
      "email" => :email,
      "count" => :count
    }.freeze

    def initialize(created_at:, birthday: nil, email: nil, count: nil)
      @created_at = created_at
      @birthday = birthday
      @email = email
      @count = count

      @_extra = {}
    end

    attr_accessor :created_at, :birthday, :email, :count

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_created_at(value)
      ::M::CoercionHelper::Coercers::DateTime.coerce(value)
    end

    def self.coerce_birthday(value)
      ::M::CoercionHelper::Coercers::Date.coerce(value)
    end

    def self.from_h(hash)
      instance =
        new(
          created_at: coerce_created_at(hash["created_at"]),
          birthday: coerce_birthday(hash["birthday"]),
          email: hash["email"],
          count: hash["count"]
        )

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["created_at"] = self.class.coerce_created_at(
        @created_at
      ) unless @created_at.nil?
      result["birthday"] = self.class.coerce_birthday(
        @birthday
      ) unless @birthday.nil?
      result["email"] = @email unless @email.nil?
      result["count"] = @count unless @count.nil?
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
