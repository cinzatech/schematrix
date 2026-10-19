require_relative "base"

module Schematrix
  module Generators
    module Templates
      # The bare-type algebra shared by every type-emitting format
      # (D7): computing the type of a schema, its variants, array
      # elements and intersections is one algorithm; only the syntax
      # of the target notation differs. Formats including this module
      # supply that syntax through the hook methods below:
      # untyped, scalar_type, array_of, string_keyed_hash,
      # null_only_type, nilable_type, element_union, join_union and
      # join_intersection.
      module TypeComposer
        include Resolver

        # The full type of a schema: the bare type underneath (D7),
        # wrapped for absence wherever the property is optional.
        def type_of(path, name, schema)
          return untyped if schema.nil?
          return null_only_type if schema.type == Set[TYPE_NULL]

          combined = bare_type(path, name, schema)
          return combined if combined == untyped
          return combined if schema.strictly_required?

          nilable_type(combined)
        end

        # The type of a property schema, addressed the way its class
        # registers: under a properties container segment. Class names
        # encode that segment as the Props module level, so a reference
        # built from the property name alone would miss it and dangle.
        def property_type_of(path, name, schema)
          type_of(path, "properties/#{name}", schema)
        end

        # Returns the type for a schema as a union string, without
        # nilability: the declared type set, the $ref target, and both
        # variant lists folded in (D1), each variant a bare type too.
        # A schema whose whole shape is a catch-all renders as a plain
        # String-keyed Hash instead of a class (D23).
        def bare_type(path, name, schema)
          return untyped if schema.nil?

          return map_type(path, name, schema) if schema.map_shaped?

          base =
            schema.type.flat_map do |type|
              case type
              when TYPE_OBJECT
                [class_name_from_path(path, name)]
              when TYPE_ARRAY
                element = array_element_type(nested_locator(path, name), schema)
                [array_of(element)]
              when TYPE_NULL
                []
              else
                # nil elements (malformed type lists) fall through the
                # scalar map's nil key to untyped, like any unknown type
                [scalar_type(type)]
              end
            end

          # A conjoined schema (D5) may combine its own terms with a
          # $ref; they intersect when the intersection flag is set,
          # union otherwise
          base << class_name_from_path(schema.ref) unless schema.ref.nil?

          base.concat(variant_types(path, name, schema.any_of, "anyOf"))
          base.concat(variant_types(path, name, schema.one_of, "oneOf"))

          return intersection(base) if schema.intersection

          union(base)
        end

        # D23: a catch-all-only schema types as a plain Hash keyed by
        # the original String property names; the values carry the
        # catch-all's own type (and coerce from it in loading, D21).
        def map_type(path, name, schema)
          slot = nested_locator(path, name)
          string_keyed_hash(map_value_type(slot, schema.additional_properties))
        end

        # The value type of a plain-Hash map slot: the catch-all's
        # bare type with an explicit nil term when the catch-all
        # admits nulls. Unlike optional slots there is no absence
        # nilability here: a missing key is not a nil value.
        def map_value_type(path, schema)
          return untyped if schema.nil? || schema.untyped?
          return scalar_type(TYPE_NULL) if schema.type == Set[TYPE_NULL]

          terms = [bare_type(path, "additionalProperties", schema)]
          terms << scalar_type(TYPE_NULL) if schema.type.include?(TYPE_NULL)
          union(terms)
        end

        # D13 element union: the union of prefix item types, plus the
        # items type when present, plus untyped whenever the tail is
        # open (no items). items: false closes the tail and adds no
        # term. Inline object prefix items fall back to untyped (no
        # stable class name); $ref items keep their class; map-shaped
        # items are plain Hashes (D23).
        def array_element_type(path, schema)
          terms =
            schema.prefix_items.map { |item| prefix_item_type(path, item) }.uniq
          if schema.items.nil?
            terms << untyped
          elsif !schema.items.type.include?(TYPE_BOTTOM)
            terms << type_of(path, "items", schema.items)
          end

          element_union(union(terms), terms)
        end

        def prefix_item_type(path, item)
          return untyped if item.type.include?(TYPE_OBJECT) && !item.map_shaped?

          type_of(path, "prefixItems", item)
        end

        # D5 conjoin: distinct declarations intersect syntactically,
        # even if uninhabited. untyped is the identity; an empty
        # conjunction falls back to untyped.
        def intersection(types)
          terms = types.reject { |type| type == untyped }
          return untyped if terms.empty?
          return terms.first if terms.size == 1

          join_intersection(terms)
        end

        # Computes the bare type of each variant branch under its
        # positional path segment (anyOf_0, oneOf_1, ...). Shared by
        # both variant lists: the keyword only names the path segment.
        def variant_types(path, name, variants, keyword)
          variant_path = nested_locator(path, name)
          variants.each_with_index.map do |variant, index|
            bare_type(variant_path, "#{keyword}_#{index}", variant)
          end
        end

        def union(types)
          return untyped if types.empty?
          return untyped if types.include?(untyped)

          return types.first if types.size == 1

          join_union(types)
        end
      end
    end
  end
end
