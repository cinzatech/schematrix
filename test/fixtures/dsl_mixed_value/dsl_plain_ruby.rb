module M
  module Dsl
    module Schema
      ORIGINAL_KEYS = { "option" => :option }.freeze

      def self.build(&block)
        builder = Builder.new
        yield builder
        builder.to_h
      end

      def option(value = nil, &block)
        if block
          child = M::Dsl::Schema::Props::Option.build(&block)
          current = dsl_fields["option"]
          dsl_fields["option"] = (
            if current.is_a?(Hash)
              current.merge(child)
            else
              child
            end
          )
        else
          dsl_fields["option"] = value
        end
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
