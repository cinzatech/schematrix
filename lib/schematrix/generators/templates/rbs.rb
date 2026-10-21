require_relative "base"
require_relative "rbs_notation"
require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the RBS generator
      class Rbs < Base
        include TypeComposer
        include RbsNotation

        private

        def rbs_attr_accessors
          return "" if @properties.nil?

          @properties
            .map do |name, prop_schema|
              "attr_accessor #{name}: #{
                property_type_of(@path, name, prop_schema)
              }"
            end
            .join("\n")
        end

        def rbs_initialize_params
          return "" if @properties.nil?

          @properties
            .map do |name, schema|
              type = property_type_of(@path, name, schema)
              if schema&.strictly_required?
                "#{name}: #{type}"
              else
                "?#{name}: #{type}"
              end
            end
            .join(", ")
        end

        def rbs_additional_properties_type
          @rbs_additional_properties_type ||=
            type_of(@path, "additional_properties", @additional_properties)
        end
      end
    end
  end
end
