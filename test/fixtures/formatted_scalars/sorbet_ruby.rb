# typed: strict

module M
  class Schema
    extend T::Sig

    ORIGINAL_KEYS =
      T.let(
        {
          "created_at" => :created_at,
          "birthday" => :birthday,
          "email" => :email,
          "count" => :count
        }.freeze,
        T::Hash[String, Symbol]
      )

    sig do
      params(
        created_at: Time,
        birthday: T.nilable(Date),
        email: T.nilable(String),
        count: T.nilable(Integer)
      ).void
    end
    def initialize(created_at:, birthday: nil, email: nil, count: nil)
      @created_at = created_at
      @birthday = birthday
      @email = email
      @count = count

      @_extra = T.let({}, T::Hash[String, T.anything])
    end

    sig { returns(Time) }
    attr_accessor :created_at

    sig { returns(T.nilable(Date)) }
    attr_accessor :birthday

    sig { returns(T.nilable(String)) }
    attr_accessor :email

    sig { returns(T.nilable(Integer)) }
    attr_accessor :count

    sig { params(key: String).returns(T.anything) }
    def [](key)
      @_extra[key]
    end

    sig { params(key: String, value: T.anything).returns(T.anything) }
    def []=(key, value)
      @_extra[key] = value
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_created_at(value)
      ::M::Schematrix::Coercers::DateTime.coerce(value)
    end

    sig { params(value: T.untyped).returns(T.untyped) }
    def self.coerce_birthday(value)
      ::M::Schematrix::Coercers::Date.coerce(value)
    end

    sig { params(hash: T::Hash[String, T.untyped]).returns(Schema) }
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

    sig { returns(T::Hash[String, T.untyped]) }
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

  module Schematrix
    module Coercers
      module DateTime
        require "time"

        extend T::Sig
        sig { params(value: T.untyped).returns(T.untyped) }
        def self.coerce(value)
          case value
          when String
            ::Time.iso8601(value)
          when ::Time
            value.iso8601
          else
            value
          end
        end
      end

      module Date
        require "date"

        extend T::Sig
        sig { params(value: T.untyped).returns(T.untyped) }
        def self.coerce(value)
          case value
          when String
            ::Date.iso8601(value)
          when ::Date
            value.iso8601
          else
            value
          end
        end
      end
    end
  end
end
