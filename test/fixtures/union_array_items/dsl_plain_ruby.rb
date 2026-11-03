module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "tags" => :tags }.freeze

      def self.build(&block)
        builder = Builder.new
        builder.instance_exec(&block)
        builder.to_h
      end

      def tags(*values)
        target = (dsl_fields["tags"] ||= [])
        target.concat(values)
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
