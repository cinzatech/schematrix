require "time"
require "date"

module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = {
        "created_at" => :created_at,
        "birthday" => :birthday,
        "email" => :email,
        "count" => :count
      }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def created_at(value)
        dsl_fields["created_at"] = (value.is_a?(::Time) ? value.iso8601 : value)
        self
      end

      def birthday(value)
        dsl_fields["birthday"] = (value.is_a?(::Date) ? value.iso8601 : value)
        self
      end

      def email(value)
        dsl_fields["email"] = value
        self
      end

      def count(value)
        dsl_fields["count"] = value
        self
      end

      def extra(key, value)
        dsl_fields[key] = value
        self
      end

      def to_h
        dsl_fields.dup
      end

      private

      def dsl_fields
        @dsl_fields ||= {}
      end

      class Builder
        include ::M::Dsl::Schema
      end
    end
  end
end
