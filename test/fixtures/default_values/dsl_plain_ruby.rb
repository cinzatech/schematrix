module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "color" => :color, "count" => :count }.freeze

      def self.build(&block)
        builder = Builder.new
        yield builder
        builder.to_h
      end

      def color(value)
        dsl_fields["color"] = value
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
