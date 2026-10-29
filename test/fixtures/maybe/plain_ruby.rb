require_relative "coercion_helper"

module M
  class Schema
    ORIGINAL_KEYS = {
      "firstName" => :first_name,
      "age" => :age,
      "tag" => :tag,
      "address" => :address
    }.freeze

    def initialize(
      first_name:,
      age: Maybe.empty,
      tag: Maybe.from("none"),
      address: Maybe.empty
    )
      @first_name = first_name
      @age = age
      @tag = tag
      @address = address

      @_extra = {}
    end

    attr_accessor :first_name, :age, :tag, :address

    def [](key)
      @_extra[key]
    end

    def []=(key, value)
      @_extra[key] = value
    end

    def self.coerce_address(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Props::Address]
      )
    end

    def self.from_h(hash)
      instance =
        new(
          first_name: hash["firstName"],
          age: hash.key?("age") ? M::Maybe.from(hash["age"]) : M::Maybe.empty,
          address:
            (
              if hash.key?("address")
                M::Maybe.from(coerce_address(hash["address"]))
              else
                M::Maybe.empty
              end
            )
        )
      instance.tag = M::Maybe.from(hash["tag"]) if hash.key?("tag")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      @age.when_present { |value| result["age"] = value }
      @tag.when_present { |value| result["tag"] = value }
      @address.when_present do |value|
        result["address"] = self.class.coerce_address(value)
      end
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
