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
        dsl_fields["created_at"] = value
        self
      end

      def birthday(value)
        dsl_fields["birthday"] = value
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
        @fields ||= {}
      end

      class Builder
        include Schema
      end
    end
  end
end
