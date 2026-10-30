require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # Common functions for producing Sorbet output
      module SorbetHelpers
        include TypeComposer

        # Sorbet's spelling of the unconstrained type.
        SORBET_TYPE_ANYTHING = "T.anything"

        def untyped = SORBET_TYPE_ANYTHING

        # The Sorbet spelling of a [type, format] pair, read from the
        # merged scalar type table; an unknown pair renders as
        # unconstrained.
        def scalar_type(type, format = nil)
          entry = lookup_scalar_type(type, format)
          return SORBET_TYPE_ANYTHING if entry.nil?

          entry.sorbet
        end

        def array_of(element) = "T::Array[#{element}]"

        def string_keyed_hash(value) = "T::Hash[String, #{value}]"

        def null_only_type = "NilClass"

        # Absence renders through T.nilable; union and intersection
        # terms stay grouped by their constructors
        def nilable_type(combined) = "T.nilable(#{combined})"

        # Absence under the maybe option renders through the Maybe
        # generic; the nilability of the value itself stays inside
        # (Maybe[T.nilable(Integer)]), spelled by the caller.
        def maybe_type(combined) = "#{maybe_type_name}[#{combined}]"

        def element_union(combined, _terms) = combined

        def join_union(types) = "T.any(#{types.join(", ")})"

        def join_intersection(types) = "T.all(#{types.join(", ")})"

        def sorbet_additional_properties_type
          @sorbet_additional_properties_type ||=
            type_of(@path, "additional_properties", @additional_properties)
        end

        # The type of the catch-all keyword wherever a signature
        # names it: constructor, copier, and the protected reader all
        # share it.
        def sorbet_catch_all_type
          "T::Hash[String, #{sorbet_additional_properties_type}]"
        end

        def sorbet_coercion_signature
          "sig { params(value: #{SORBET_TYPE_ANYTHING}).returns(#{
            SORBET_TYPE_ANYTHING
          }) }"
        end

        # Signature of the shared coercion helpers, which also carry
        # the slot's target class.
        def sorbet_coercion_helper_signature
          "sig { params(value: #{SORBET_TYPE_ANYTHING}, klass: #{
            SORBET_TYPE_ANYTHING
          }).returns(#{SORBET_TYPE_ANYTHING}) }"
        end

        # Signature of the spec interpreter, whose second parameter is
        # the conversion spec rather than a slot helper's class.
        def sorbet_spec_helper_signature
          "sig { params(value: #{SORBET_TYPE_ANYTHING}, spec: #{
            SORBET_TYPE_ANYTHING
          }).returns(#{SORBET_TYPE_ANYTHING}) }"
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
          groups = []
          unless @properties.nil? || @properties.empty?
            groups << constructor_properties.map do |name, property|
              "#{name}: #{property_type_of(@path, name, property)}"
            end
          end
          if immutable? && !@additional_properties.nil?
            groups << "_extra: #{sorbet_catch_all_type}"
          end
          return "" if groups.empty?

          "params(#{groups.join(", ")})."
        end

        # The copier's signature: one optional keyword per property
        # and one for the catch-all, returning the receiver's own
        # class so subclasses copy as themselves. A keyword-less
        # copier omits params, which Sorbet refuses empty.
        def sorbet_with_signature
          entries =
            property_names.map do |name|
              type = property_type_of(@path, name, @properties.fetch(name))
              "#{name}: #{type}"
            end
          unless @additional_properties.nil?
            entries << "_extra: #{sorbet_catch_all_type}"
          end
          return "sig { returns(T.self_type) }" if entries.empty?

          "sig { params(#{entries.join(", ")}).returns(T.self_type) }"
        end

        # The equality signature: the other side stays top, since the
        # body narrows it with the is_a? guard.
        def sorbet_equality_signature
          "sig { params(other: #{SORBET_TYPE_ANYTHING}).returns(T::Boolean) }"
        end

        def sorbet_hash_signature
          "sig { returns(Integer) }"
        end

        def sorbet_extra_reader_signature
          "sig { returns(#{sorbet_catch_all_type}) }"
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
