require_relative "rbs_notation"

module Schematrix
  module Generators
    module Templates
      # The RBS notation of the DSL builders. Type names stay
      # relative, resolving lexically under the Dsl namespace the
      # declaration tree opens; block types carry the child builder's
      # class; setters return `instance` so chains check.
      module DslRbsNotation
        include RbsNotation

        private

        def build_signature
          "def self.build: () { (#{own_class_name}) -> void } " \
            "-> Hash[String, #{untyped}]"
        end

        def initialize_signature
          "def initialize: () -> void"
        end

        def to_h_signature
          "def to_h: () -> Hash[String, #{untyped}]"
        end

        def extra_signature
          if extra_kind == :extra_scalars
            "def extra: (String key, #{
              param_type(setter_value_type(nil, :extra_scalars, nil))
            } value) -> instance"
          else
            "def extra: (String key) { (#{extra_builder_term}) -> void } " \
              "-> instance"
          end
        end

        # One signature line per property setter.
        def dsl_rbs_setters
          return "" if @properties.nil?

          @properties
            .filter_map do |name, schema|
              setter_signature(name, setter_kind(name, schema))
            end
            .join("\n\n")
        end

        def setter_signature(name, kind)
          "def #{name}: #{setter_rbs_params(name, kind)}-> instance"
        end

        def setter_rbs_params(name, kind)
          schema = @properties[name]
          case kind
          when :scalar
            "(#{param_type(setter_value_type(name, kind, schema))} value) "
          when :object
            "() { (#{property_builder_term(name)}) -> void } "
          when :array_scalars
            "(*#{param_type(setter_value_type(name, kind, schema))} values) "
          when :array_objects
            "() { (#{element_builder_term(name)}) -> void } "
          when :mixed_array
            "(*#{untyped} values) ?{ (#{element_builder_term(name)}) -> void } "
          when :map_scalars
            "(String key, #{
              param_type(setter_value_type(name, kind, schema))
            } value) "
          when :map_objects
            "(String key) { (#{map_builder_term(name)}) -> void } "
          when :mixed_value
            "(#{untyped} value) ?{ (#{property_builder_term(name)}) -> void } "
          end
        end

        # Union types parenthesize in parameter position, so the `|`
        # binds to the parameter and not to the method type. Element
        # unions arrive parenthesized from the composer already.
        def param_type(type)
          return type unless type.include?(" | ")
          return type if type.start_with?("(")

          "(#{type})"
        end
      end
    end
  end
end
