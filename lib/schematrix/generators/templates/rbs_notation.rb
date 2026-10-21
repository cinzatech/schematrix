module Schematrix
  module Generators
    module Templates
      # The RBS notation hooks for the type algebra: how the shared
      # composer spells each construct in RBS. Shared by the RBS
      # generator and the RBS spelling of the DSL builders.
      module RbsNotation
        # RBS renders `top` where Sorbet renders T.anything. The
        # untyped spelling is retired from generated output: top is
        # the tracked top type, writes stay fully accepting but reads
        # must be narrowed.
        RBS_TYPE_TOP = "top"

        # RBS spelling per JSON Schema type name; unknown names fall
        # back to top.
        RBS_SCALAR_TYPES = {
          nil => RBS_TYPE_TOP,
          TYPE_STRING => "String",
          TYPE_INTEGER => "Integer",
          TYPE_NUMBER => "Numeric",
          TYPE_BOOLEAN => "bool",
          TYPE_NULL => "nil",
        }.freeze

        private

        def untyped = RBS_TYPE_TOP

        def scalar_type(type)
          RBS_SCALAR_TYPES.fetch(type, RBS_TYPE_TOP)
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
          return combined if combined == RBS_TYPE_TOP

          terms.size > 1 ? "(#{combined})" : combined
        end

        def join_union(types) = types.join(" | ")

        def join_intersection(types) = types.join(" & ")
      end
    end
  end
end
