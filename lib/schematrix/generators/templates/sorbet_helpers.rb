require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # Common functions for producing Sorbet output
      module SorbetHelpers
        include TypeComposer

        SORBET_TYPE_ANYTHING = "T.anything"

        # Maps JSON Schema scalar types to their Sorbet equivalents
        SORBET_SCALAR_TYPES = {
          nil => SORBET_TYPE_ANYTHING,
          TYPE_STRING => "String",
          TYPE_INTEGER => "Integer",
          TYPE_NUMBER => "Float",
          TYPE_BOOLEAN => "T::Boolean",
          TYPE_NULL => "NilClass",
          TYPE_BOTTOM => "T.noreturn",
        }.freeze

        # Sorbet syntax hooks for TypeComposer

        def untyped = SORBET_TYPE_ANYTHING

        def scalar_type(type)
          SORBET_SCALAR_TYPES.fetch(type, SORBET_TYPE_ANYTHING)
        end

        def array_of(element) = "T::Array[#{element}]"

        def string_keyed_hash(value) = "T::Hash[String, #{value}]"

        def null_only_type = "NilClass"

        # Absence renders through T.nilable; union and intersection
        # terms stay grouped by their constructors
        def nilable_type(combined) = "T.nilable(#{combined})"

        def element_union(combined, _terms) = combined

        def join_union(types) = "T.any(#{types.join(", ")})"

        def join_intersection(types) = "T.all(#{types.join(", ")})"

        # Sorbet emitters

        def sorbet_additional_properties_type
          @sorbet_additional_properties_type ||=
            type_of(@path, "additional_properties", @additional_properties)
        end

        def sorbet_coercion_signature
          "sig { params(value: #{SORBET_TYPE_ANYTHING}).returns(#{
            SORBET_TYPE_ANYTHING
          }) }"
        end

        def sorbet_from_h_signature
          [
            "sig do",
            "  params(hash: T::Hash[String, #{SORBET_TYPE_ANYTHING}])",
            "    .returns(#{own_class_name})",
            "end",
          ].join("\n")
        end

        def sorbet_to_h_signature
          "sig { returns(T::Hash[String, #{SORBET_TYPE_ANYTHING}]) }"
        end

        def sorbet_constructor_signature_params
          return "" if @properties.nil? || @properties.empty?

          params =
            @properties
              .map do |name, property|
                "#{name}: #{property_type_of(@path, name, property)}"
              end
              .join(", ")

          "params(#{params})."
        end

        def sorbet_attr_accessors
          return "" if @properties.nil?

          @properties
            .map do |name, property|
              sorbet_attr_accessor(@path, name, property)
            end
            .join("\n\n")
        end

        def sorbet_attr_accessor(path, name, property)
          raise NotImplementedError,
                "#{self.class} must implement #sorbet_attr_accessor"
        end
      end
    end
  end
end
