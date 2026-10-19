require_relative "base"
require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # RBS template class
      class Rbs < Base
        include TypeComposer

        RBS_TYPE_UNTYPED = "untyped"

        # Maps JSON Schema scalar types to their RBS equivalents
        RBS_SCALAR_TYPES = {
          nil => RBS_TYPE_UNTYPED,
          TYPE_STRING => "String",
          TYPE_INTEGER => "Integer",
          TYPE_NUMBER => "Float",
          TYPE_BOOLEAN => "bool",
          TYPE_NULL => "nil",
        }.freeze

        private

        # RBS syntax hooks for TypeComposer

        def untyped = RBS_TYPE_UNTYPED

        def scalar_type(type)
          RBS_SCALAR_TYPES.fetch(type, RBS_TYPE_UNTYPED)
        end

        def array_of(element) = "Array[#{element}]"

        def string_keyed_hash(value) = "Hash[String, #{value}]"

        def null_only_type = "nil"

        # Absence renders as a nilable union; multi-term unions
        # parenthesize so the suffix binds to the whole union.
        def nilable_type(combined)
          multi = combined.include?(" | ") || combined.include?(" & ")
          multi ? "(#{combined})?" : "#{combined}?"
        end

        # Array element unions parenthesize when multiple terms remain,
        # keeping the union one element type inside Array[...]
        def element_union(combined, terms)
          return combined if combined == RBS_TYPE_UNTYPED

          terms.size > 1 ? "(#{combined})" : combined
        end

        def join_union(types) = types.join(" | ")

        def join_intersection(types) = types.join(" & ")

        # RBS emitters

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
