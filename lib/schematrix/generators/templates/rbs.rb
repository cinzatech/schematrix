require_relative "base"
require_relative "ruby_helpers"
require_relative "rbs_notation"
require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the RBS generator
      class Rbs < Base
        include RubyHelpers
        include TypeComposer
        include RbsNotation

        private

        def rbs_attr_accessors
          return "" if @properties.nil?

          keyword = immutable? ? "attr_reader" : "attr_accessor"
          @properties
            .map do |name, prop_schema|
              "#{keyword} #{name}: #{
                property_type_of(@path, name, prop_schema)
              }"
            end
            .join("\n")
        end

        # Mirrors the generated Ruby constructor: the same required
        # keywords (null-typed required properties included) in the
        # same required-first order, and the catch-all keyword once
        # the class is immutable and open.
        def rbs_initialize_params
          return "" if @properties.nil?

          params =
            constructor_properties.map do |name, schema|
              type = property_type_of(@path, name, schema)
              if schema.constructor_required?
                "#{name}: #{type}"
              else
                "?#{name}: #{type}"
              end
            end
          if immutable? && !@additional_properties.nil?
            params << "?_extra: Hash[String, #{rbs_additional_properties_type}]"
          end
          params.join(", ")
        end

        # The copier's keywords: every property optional, the
        # catch-all replaceable as a whole when the class is open.
        def rbs_with_params
          params =
            (@properties.nil? ? [] : @properties).map do |name, schema|
              "?#{name}: #{property_type_of(@path, name, schema)}"
            end
          unless @additional_properties.nil?
            params << "?_extra: Hash[String, #{rbs_additional_properties_type}]"
          end
          params.join(", ")
        end

        def rbs_additional_properties_type
          @rbs_additional_properties_type ||=
            type_of(@path, "additional_properties", @additional_properties)
        end
      end
    end
  end
end
