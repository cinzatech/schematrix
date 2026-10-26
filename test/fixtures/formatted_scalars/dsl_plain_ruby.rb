module M
  module Dsl
    class Schema
      ORIGINAL_KEYS = {
        "created_at" => :created_at,
        "birthday" => :birthday,
        "email" => :email,
        "count" => :count
      }.freeze

      def self.build(&block)
        builder = new
        yield builder
        builder.to_h
      end

      def initialize
        @fields = {}
      end

      def created_at(value)
        @fields["created_at"] = value
        self
      end

      def birthday(value)
        @fields["birthday"] = value
        self
      end

      def email(value)
        @fields["email"] = value
        self
      end

      def count(value)
        @fields["count"] = value
        self
      end

      def extra(key, value)
        @fields[key] = value
        self
      end

      def to_h
        @fields.dup
      end
    end
  end
end
