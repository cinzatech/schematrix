module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "name" => :name }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def name(value)
        dsl_fields["name"] = value
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
