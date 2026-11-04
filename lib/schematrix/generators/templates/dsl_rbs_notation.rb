require_relative "rbs_notation"

module Schematrix
  module Generators
    module Templates
      # The RBS notation of the DSL builders. Type names stay
      # relative, resolving lexically under the Dsl namespace the
      # declaration tree opens; setters return `instance` so chains
      # check. Blocks are declared bare: RBS can bind a block's self
      # to the child builder, but syntax_tree-rbs 1.0 drops the
      # binding when it formats, so the output does not carry it.
      module DslRbsNotation
        include RbsNotation

        private

        # A definition file is data: the String spelling of the DSL
        # date slots, mirroring the Sorbet signatures. See DslValues.
        def scalar_type(type, format = nil)
          entry = lookup_scalar_type(type, format)
          return super unless entry && dsl_builtin_date_entry?(entry)

          "String"
        end

        def build_signature
          "def self.build: () #{bound_block(own_class_name)} " \
            "-> Hash[String, #{untyped}]"
        end

        def fields_signature
          "def dsl_fields: () -> Hash[String, #{untyped}]"
        end

        def builder_class
          <<~RBS
            class Builder
              include #{absolute_own_name}
            end
          RBS
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
            "def extra: (String key) #{bound_block(extra_builder_term)} " \
              "-> instance"
          end
        end

        # One signature line per property setter, under the comment
        # its description becomes.
        def dsl_rbs_setters
          return "" if @properties.nil?

          @properties
            .filter_map do |name, schema|
              with_property_comment(
                schema,
                setter_signature(name, setter_kind(name, schema)),
              )
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
            "() #{bound_block(property_builder_term(name))} "
          when :array_scalars
            "(*#{param_type(setter_value_type(name, kind, schema))} values) "
          when :array_objects
            "() #{bound_block(element_builder_term(name))} "
          when :mixed_array
            "(*#{untyped} values) ?#{bound_block(element_builder_term(name))} "
          when :map_scalars
            "(String key, #{
              param_type(setter_value_type(name, kind, schema))
            } value) "
          when :map_objects
            "(String key) #{bound_block(map_builder_term(name))} "
          when :mixed_value
            "(#{untyped} value) ?#{bound_block(property_builder_term(name))} "
          end
        end

        # A block that takes nothing. The child builder it runs on is
        # not declared: `[self: term]` is the RBS spelling, and the
        # formatter removes it.
        def bound_block(_term)
          "{ () -> void }"
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
