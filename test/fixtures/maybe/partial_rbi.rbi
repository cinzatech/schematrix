# typed: strict

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
      end

      sig { returns(Maybe[T.nilable(String)]) }
      def first_name
      end

      sig { params(first_name: Maybe[T.nilable(String)]).void }
      def first_name=(first_name)
      end

      sig { returns(Maybe[T.nilable(Integer)]) }
      def age
      end

      sig { params(age: Maybe[T.nilable(Integer)]).void }
      def age=(age)
      end

      sig { returns(Maybe[T.nilable(String)]) }
      def tag
      end

      sig { params(tag: Maybe[T.nilable(String)]).void }
      def tag=(tag)
      end

      sig { returns(Maybe[T.nilable(Partial::Schema::Props::Address)]) }
      def address
      end

      sig do
        params(address: Maybe[T.nilable(Partial::Schema::Props::Address)]).void
      end
      def address=(address)
      end

      sig { returns(Maybe[T.nilable(T::Array[String])]) }
      def tags
      end

      sig { params(tags: Maybe[T.nilable(T::Array[String])]).void }
      def tags=(tags)
      end

      sig { returns(Maybe[T.nilable(T::Hash[String, Integer])]) }
      def labels
      end

      sig { params(labels: Maybe[T.nilable(T::Hash[String, Integer])]).void }
      def labels=(labels)
      end

      sig { returns(Maybe[T.nilable(String)]) }
      def nickname
      end

      sig { params(nickname: Maybe[T.nilable(String)]).void }
      def nickname=(nickname)
      end

      sig { returns(Maybe[T.nilable(T::Array[NilClass])]) }
      def voids
      end

      sig { params(voids: Maybe[T.nilable(T::Array[NilClass])]).void }
      def voids=(voids)
      end

      sig { params(key: String).returns(T.anything) }
      def [](key)
      end

      sig { params(key: String, value: T.anything).returns(T.anything) }
      def []=(key, value)
      end

      sig { params(value: T.anything).returns(T.anything) }
      def self.coerce_address(value)
      end

      sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
      def self.from_h(hash)
      end

      sig { returns(T::Hash[String, T.anything]) }
      def to_h
      end
    end
  end
end
