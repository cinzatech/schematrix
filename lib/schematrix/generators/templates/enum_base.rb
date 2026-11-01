require_relative "base"

module Schematrix
  module Generators
    module Templates
      # Shares member folding and bidirectional coercion across enum formats.
      class EnumBase < Base
        extend Resolver

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

        def initialize(members:, **)
          super(properties: nil, additional_properties: nil, **)
          @members = members
        end

        private

        def serialized_type
          @members.first.last.is_a?(Integer) ? "Integer" : "String"
        end

        def coerce_body
          <<~RUBY
            case value
            when ::#{serialized_type} then deserialize(value)
            when ::#{@module_name}::#{@class_name} then value.serialize
            else value
            end
          RUBY
        end
      end
    end
  end
end
