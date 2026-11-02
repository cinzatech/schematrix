require_relative "base"
require_relative "coercions"

module Schematrix
  module Generators
    module Templates
      # Shares member folding and bidirectional coercion across enum formats.
      class EnumBase < Base
        extend Resolver
        include Coercions

        def self.fold_members(values)
          names = {}
          values.compact.uniq.map do |value|
            clean = value.to_s.gsub(/[^a-zA-Z0-9]/, " ").strip
            clean = value.to_s.unpack1("H*") if clean.empty?
            clean = "Empty" if clean.empty?
            name = pascal_case(clean).sub(/\A(\d)/, 'N\1')
            if names.key?(name)
              raise OutputCollisionError,
                    "Enum values #{names.fetch(name).inspect} and " \
                      "#{value.inspect} fold onto #{name}"
            end
            names[name] = value
            [name, value]
          end
        end

        def initialize(members:, format: nil, **)
          super(properties: nil, additional_properties: nil, **)
          @members = members
          @format = format
        end

        private

        def document_type
          @members.first.last.is_a?(Integer) ? "Integer" : "String"
        end

        def format_entry
          lookup_scalar_type(document_type.downcase, @format)
        end

        def serialized_type
          return document_type unless format_entry&.coerces?

          type = format_entry.rbs
          type.match?(/\A[A-Z]\w*(?:::[A-Z]\w*)*\z/) ? "::#{type}" : type
        end

        def format_conversion(expression)
          return expression unless format_entry&.coerces?

          "#{coercion_target(format_entry.coercer)}.coerce(#{expression})"
        end

        def used_builtin_coercers
          coercer = format_entry&.coercer
          Schematrix::Coercers::BUILTIN.include?(coercer) ? [coercer] : []
        end

        def coerce_body
          <<~RUBY
            case value
            when ::#{document_type} then deserialize(#{format_conversion("value")})
            when ::#{@module_name}::#{@class_name} then #{format_conversion("value.serialize")}
            else value
            end
          RUBY
        end
      end
    end
  end
end
