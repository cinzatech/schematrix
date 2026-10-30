# typed: strict

module M
  class Schema
    ORIGINAL_KEYS = {
      "created_at" => :created_at,
      "birthday" => :birthday,
      "email" => :email,
      "count" => :count
    }.freeze

    sig do
      params(
        created_at: Time,
        birthday: T.nilable(Date),
        email: T.nilable(String),
        count: T.nilable(Integer)
      ).void
    end
    def initialize(created_at:, birthday: nil, email: nil, count: nil)
    end

    sig { returns(Time) }
    def created_at
    end

    sig { params(created_at: Time).void }
    def created_at=(created_at)
    end

    sig { returns(T.nilable(Date)) }
    def birthday
    end

    sig { params(birthday: T.nilable(Date)).void }
    def birthday=(birthday)
    end

    sig { returns(T.nilable(String)) }
    def email
    end

    sig { params(email: T.nilable(String)).void }
    def email=(email)
    end

    sig { returns(T.nilable(Integer)) }
    def count
    end

    sig { params(count: T.nilable(Integer)).void }
    def count=(count)
    end

    sig { params(key: String).returns(T.anything) }
    def [](key)
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_created_at(value)
    end

    sig { params(value: T.anything).returns(T.anything) }
    def self.coerce_birthday(value)
    end

    sig { params(hash: T::Hash[String, T.anything]).returns(Schema) }
    def self.from_h(hash)
    end

    sig { returns(T::Hash[String, T.anything]) }
    def to_h
    end
  end

  module Schematrix
    module Coercers
      module DateTime
        extend T::Sig
        sig { params(value: T.anything).returns(T.anything) }
        def self.coerce(value)
        end
      end

      module Date
        extend T::Sig
        sig { params(value: T.anything).returns(T.anything) }
        def self.coerce(value)
        end
      end
    end
  end
end
