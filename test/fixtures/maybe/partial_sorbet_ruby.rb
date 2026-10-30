# typed: strict

require_relative "../coercion_helper"

module M
  class Partial
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
          first_name: Maybe[T.nilable(String)],
          nickname: Maybe[T.nilable(String)],
          age: Maybe[T.nilable(Integer)],
          tag: Maybe[T.nilable(String)],
          address: Maybe[T.nilable(Partial::Schema::Props::Address)],
          tags: Maybe[T.nilable(T::Array[String])],
          labels: Maybe[T.nilable(T::Hash[String, Integer])],
          voids: Maybe[T.nilable(T::Array[NilClass])]
        ).void
      end
      def initialize(
        first_name: Maybe.empty,
        nickname: Maybe.empty,
        age: Maybe.empty,
        tag: Maybe.empty,
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

      sig { returns(Maybe[T.nilable(String)]) }
      attr_accessor :first_name

      sig { returns(Maybe[T.nilable(Integer)]) }
      attr_accessor :age

      sig { returns(Maybe[T.nilable(String)]) }
      attr_accessor :tag

      sig { returns(Maybe[T.nilable(Partial::Schema::Props::Address)]) }
      attr_accessor :address

      sig { returns(Maybe[T.nilable(T::Array[String])]) }
      attr_accessor :tags

      sig { returns(Maybe[T.nilable(T::Hash[String, Integer])]) }
      attr_accessor :labels

      sig { returns(Maybe[T.nilable(String)]) }
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
          [:class, M::Partial::Schema::Props::Address]
        )
      end

      sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
      def self.from_h(hash)
        instance =
          new(
            first_name:
              T.unsafe(
                (
                  if hash.key?("firstName")
                    M::Maybe.from(hash["firstName"])
                  else
                    M::Maybe.empty
                  end
                )
              ),
            age:
              T.unsafe(
                hash.key?("age") ? M::Maybe.from(hash["age"]) : M::Maybe.empty
              ),
            tag:
              T.unsafe(
                hash.key?("tag") ? M::Maybe.from(hash["tag"]) : M::Maybe.empty
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
            nickname:
              T.unsafe(
                (
                  if hash.key?("nickname")
                    M::Maybe.from(hash["nickname"])
                  else
                    M::Maybe.empty
                  end
                )
              ),
            voids:
              T.unsafe(
                (
                  if hash.key?("voids")
                    M::Maybe.from(hash["voids"])
                  else
                    M::Maybe.empty
                  end
                )
              )
          )

        hash.each do |key, value|
          next if ORIGINAL_KEYS.key?(key)

          instance[key] = value
        end
        instance
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def to_h
        result = {}
        case @first_name
        when M::Maybe::Present
          result["firstName"] = @first_name.value
        when M::Maybe::Absent
          nil
        else
          T.absurd(@first_name)
        end
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
        case @nickname
        when M::Maybe::Present
          result["nickname"] = @nickname.value
        when M::Maybe::Absent
          nil
        else
          T.absurd(@nickname)
        end
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
end
