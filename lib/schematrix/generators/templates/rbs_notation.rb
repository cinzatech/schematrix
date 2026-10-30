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

        private

        def untyped = RBS_TYPE_TOP

        # The RBS spelling of a [type, format] pair, read from the
        # merged scalar type table; an unknown pair renders as top.
        def scalar_type(type, format = nil)
          entry = lookup_scalar_type(type, format)
          return RBS_TYPE_TOP if entry.nil?

          entry.rbs
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

        # Absence under the maybe option renders through the Maybe
        # generic, named absolutely: an RBS type name is global, so
        # lexical resolution cannot stand in for it.
        def maybe_type(combined) = "#{maybe_reference}[#{combined}]"

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
