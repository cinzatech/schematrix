module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "entries" => :entries }.freeze

      def self.build(&block)
        builder = Builder.new
        yield builder
        builder.to_h
      end

      def entries(&block)
        target = (dsl_fields["entries"] ||= [])
        target << M::Dsl::Schema::Props::Entries::Items.build(&block)
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
