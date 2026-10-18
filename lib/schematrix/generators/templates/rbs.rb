require_relative "base"

module Schematrix
  module Generators
    module Templates
      # RBS template class
      class Rbs < Base
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

        def rbs_attr_accessors
          return "" if @properties.nil?

          @properties
            .map do |name, prop_schema|
              "attr_accessor #{name}: #{rbs_type(@path, name, prop_schema)}"
            end
            .join("\n")
        end

        def rbs_initialize_params
          return "" if @properties.nil?

          @properties
            .map do |name, schema|
              type = rbs_type(@path, name, schema)
              if strictly_required?(schema)
                "#{name}: #{type}"
              else
                "?#{name}: #{type}"
              end
            end
            .join(", ")
        end

        # Returns the RBS type string for a given property schema.
        #
        # The type is made nilable (Type?) for optional properties so the
        # attr_accessor accurately reflects that the value may be nil after
        # construction. The bare union underneath comes from
        # bare_rbs_type; variants join it without their own nilability
        # since the outer property owns it (D7).
        def rbs_type(path, name, schema)
          return RBS_TYPE_UNTYPED if schema.nil?
          return "nil" if schema.type == Set["null"]

          combined = bare_rbs_type(path, name, schema)
          return combined if combined == RBS_TYPE_UNTYPED
          return combined if strictly_required?(schema)

          multi = combined.include?(" | ") || combined.include?(" & ")
          multi ? "(#{combined})?" : "#{combined}?"
        end

        # Returns the type for a schema as a union string, without
        # nilability: the declared type set, the $ref target, and both
        # variant lists folded in (D1), each variant a bare type too.
        def bare_rbs_type(path, name, schema)
          return RBS_TYPE_UNTYPED if schema.nil?

          base =
            schema.type.flat_map do |type|
              case type
              when "object"
                [class_name_from_path(path, name)]
              when "array"
                element = array_element_type(nested_locator(path, name), schema)
                ["Array[#{element}]"]
              when "null"
                []
              when nil
                RBS_TYPE_UNTYPED
              else
                [RBS_SCALAR_TYPES.fetch(type, RBS_TYPE_UNTYPED)]
              end
            end

          # TODO: Schemas may combine a $ref and some overrides
          base << class_name_from_path(schema.ref) unless schema.ref.nil?

          base.concat(variant_types(path, name, schema.any_of, "anyOf"))
          base.concat(variant_types(path, name, schema.one_of, "oneOf"))

          return intersect_types(base) if schema.intersection

          combine_types(base)
        end

        # D13 element union: the union of prefix item types, plus the
        # items type when present, plus untyped whenever the tail is
        # open (no items). items: false closes the tail and adds no
        # term. Inline object prefix items fall back to untyped (no
        # stable class name); $ref items keep their class.
        def array_element_type(path, schema)
          terms =
            schema.prefix_items.map { |item| prefix_item_type(path, item) }.uniq
          if schema.items.nil?
            terms << RBS_TYPE_UNTYPED
          elsif !schema.items.type.include?(TYPE_BOTTOM)
            terms << rbs_type(path, "items", schema.items)
          end

          combined = combine_types(terms)
          return combined if combined == RBS_TYPE_UNTYPED

          terms.size > 1 ? "(#{combined})" : combined
        end

        def prefix_item_type(path, item)
          return RBS_TYPE_UNTYPED if item.type.include?(TYPE_OBJECT)

          rbs_type(path, "prefixItems", item)
        end

        # D5 conjoin: distinct declarations intersect syntactically
        # (String & Integer), even if uninhabited. untyped is the
        # identity; an empty conjunction falls back to untyped.
        def intersect_types(types)
          terms = types.reject { |type| type == RBS_TYPE_UNTYPED }
          return RBS_TYPE_UNTYPED if terms.empty?
          return terms.first if terms.size == 1

          terms.join(" & ")
        end

        # Computes the bare type of each variant branch under its
        # positional path segment (anyOf_0, oneOf_1, ...). Shared by
        # both variant lists: the keyword only names the path segment.
        def variant_types(path, name, variants, keyword)
          variants.each_with_index.map do |variant, index|
            variant_path = nested_locator(path, name)
            bare_rbs_type(variant_path, "#{keyword}_#{index}", variant)
          end
        end

        def combine_types(types)
          return RBS_TYPE_UNTYPED if types.empty?
          return RBS_TYPE_UNTYPED if types.include?(RBS_TYPE_UNTYPED)

          return types.first if types.size == 1

          types.join(" | ")
        end

        def rbs_additional_properties_type
          rbs_type(@path, "additional_properties", @additional_properties)
        end
      end
    end
  end
end
