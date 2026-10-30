require_relative "../coercion_helper"

module M
  class Partial
    class Schema
      ORIGINAL_KEYS = {
        "firstName" => :first_name,
        "age" => :age,
        "tag" => :tag,
        "address" => :address,
        "tags" => :tags,
        "labels" => :labels,
        "nickname" => :nickname,
        "voids" => :voids
      }.freeze

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

        @_extra = {}
      end

      attr_accessor :first_name,
                    :age,
                    :tag,
                    :address,
                    :tags,
                    :labels,
                    :nickname,
                    :voids

      def [](key)
        @_extra[key]
      end

      def []=(key, value)
        @_extra[key] = value
      end

      def self.coerce_address(value)
        ::M::CoercionHelper.coerce_spec(
          value,
          [:class, M::Partial::Schema::Props::Address]
        )
      end

      def self.from_h(hash)
        instance =
          new(
            first_name:
              (
                if hash.key?("firstName")
                  M::Maybe.from(hash["firstName"])
                else
                  M::Maybe.empty
                end
              ),
            age: hash.key?("age") ? M::Maybe.from(hash["age"]) : M::Maybe.empty,
            tag: hash.key?("tag") ? M::Maybe.from(hash["tag"]) : M::Maybe.empty,
            address:
              (
                if hash.key?("address")
                  M::Maybe.from(coerce_address(hash["address"]))
                else
                  M::Maybe.empty
                end
              ),
            tags:
              hash.key?("tags") ? M::Maybe.from(hash["tags"]) : M::Maybe.empty,
            labels:
              (
                if hash.key?("labels")
                  M::Maybe.from(hash["labels"])
                else
                  M::Maybe.empty
                end
              ),
            nickname:
              (
                if hash.key?("nickname")
                  M::Maybe.from(hash["nickname"])
                else
                  M::Maybe.empty
                end
              ),
            voids:
              hash.key?("voids") ? M::Maybe.from(hash["voids"]) : M::Maybe.empty
          )

        hash.each do |key, value|
          next if ORIGINAL_KEYS.key?(key)

          instance[key] = value
        end
        instance
      end

      def to_h
        result = {}
        @first_name.when_present { |value| result["firstName"] = value }
        @age.when_present { |value| result["age"] = value }
        @tag.when_present { |value| result["tag"] = value }
        @address.when_present do |value|
          result["address"] = self.class.coerce_address(value)
        end
        @tags.when_present { |value| result["tags"] = value }
        @labels.when_present { |value| result["labels"] = value }
        @nickname.when_present { |value| result["nickname"] = value }
        @voids.when_present { |value| result["voids"] = value }
        @_extra.each { |key, value| result[key] = value }
        result
      end
    end
  end
end
