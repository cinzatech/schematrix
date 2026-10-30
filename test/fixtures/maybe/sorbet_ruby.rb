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
          "address" => :address,
          "tags" => :tags,
          "labels" => :labels,
          "nickname" => :nickname,
          "voids" => :voids
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        first_name: String,
        nickname: T.nilable(String),
        age: Maybe[T.nilable(Integer)],
        tag: Maybe[T.nilable(String)],
        address: Maybe[T.nilable(Schema::Props::Address)],
        tags: Maybe[T.nilable(T::Array[String])],
        labels: Maybe[T.nilable(T::Hash[String, Integer])],
        voids: Maybe[T.nilable(T::Array[NilClass])]
      ).void
    end
    def initialize(
      first_name:,
      nickname:,
      age: Maybe.empty,
      tag: Maybe.from("none"),
      address: Maybe.empty,
      tags: Maybe.empty,
      labels: Maybe.empty,
      voids: Maybe.empty
    )
      @first_name = first_name
      @age = age
      @tag = tag
      @address = address
      @tags = tags
      @labels = labels
      @nickname = nickname
      @voids = voids

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(String) }
    attr_accessor :first_name

    sig { returns(Maybe[T.nilable(Integer)]) }
    attr_accessor :age

    sig { returns(Maybe[T.nilable(String)]) }
    attr_accessor :tag

    sig { returns(Maybe[T.nilable(Schema::Props::Address)]) }
    attr_accessor :address

    sig { returns(Maybe[T.nilable(T::Array[String])]) }
    attr_accessor :tags

    sig { returns(Maybe[T.nilable(T::Hash[String, Integer])]) }
    attr_accessor :labels

    sig { returns(T.nilable(String)) }
    attr_accessor :nickname

    sig { returns(Maybe[T.nilable(T::Array[NilClass])]) }
    attr_accessor :voids

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
            ),
          tags:
            T.unsafe(
              hash.key?("tags") ? M::Maybe.from(hash["tags"]) : M::Maybe.empty
            ),
          labels:
            T.unsafe(
              (
                if hash.key?("labels")
                  M::Maybe.from(hash["labels"])
                else
                  M::Maybe.empty
                end
              )
            ),
          nickname: hash["nickname"],
          voids:
            T.unsafe(
              hash.key?("voids") ? M::Maybe.from(hash["voids"]) : M::Maybe.empty
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
      case @tags
      when M::Maybe::Present
        result["tags"] = @tags.value
      when M::Maybe::Absent
        nil
      else
        T.absurd(@tags)
      end
      case @labels
      when M::Maybe::Present
        result["labels"] = @labels.value
      when M::Maybe::Absent
        nil
      else
        T.absurd(@labels)
      end
      result["nickname"] = @nickname unless @nickname.nil?
      case @voids
      when M::Maybe::Present
        result["voids"] = @voids.value
      when M::Maybe::Absent
        nil
      else
        T.absurd(@voids)
      end
      @_extra.each { |key, value| result[key] = value }
      result
    end
  end
end
