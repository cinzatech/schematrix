# typed: strict

require_relative "coercion_helper"

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "firstName" => :first_name,
          "age" => :age,
          "tag" => :tag,
          "address" => :address
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        first_name: String,
        age: Maybe[Integer],
        tag: Maybe[String],
        address: Maybe[Schema::Props::Address]
      ).void
    end
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

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(String) }
    attr_accessor :first_name

    sig { returns(Maybe[Integer]) }
    attr_accessor :age

    sig { returns(Maybe[String]) }
    attr_accessor :tag

    sig { returns(Maybe[Schema::Props::Address]) }
    attr_accessor :address

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_address(value)
      ::M::CoercionHelper.coerce_spec(
        value,
        [:class, M::Schema::Props::Address]
      )
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
    def self.from_h(hash)
      instance =
        new(
          first_name: hash["firstName"],
          age:
            T.unsafe(
              hash.key?("age") ? M::Maybe.from(hash["age"]) : M::Maybe.empty
            ),
          address:
            T.unsafe(
              (
                if hash.key?("address")
                  M::Maybe.from(coerce_address(hash["address"]))
                else
                  M::Maybe.empty
                end
              )
            )
        )
      instance.tag = T.unsafe(M::Maybe.from(hash["tag"])) if hash.key?("tag")

      hash.each do |key, value|
        next if ORIGINAL_KEYS.key?(key)

        instance[key] = value
      end
      instance
    end

    sig { returns(T::Hash[String, T.untyped]) }
    def to_h
      result = {}
      result["firstName"] = @first_name unless @first_name.nil?
      case @age
      when M::Maybe::Present
        result["age"] = @age.value
      when M::Maybe::Absent
        nil
      else
        T.absurd(@age)
      end
      case @tag
      when M::Maybe::Present
        result["tag"] = @tag.value
      when M::Maybe::Absent
        nil
      else
        T.absurd(@tag)
      end
      case @address
      when M::Maybe::Present
        result["address"] = self.class.coerce_address(@address.value)
      when M::Maybe::Absent
        nil
      else
        T.absurd(@address)
      end
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
