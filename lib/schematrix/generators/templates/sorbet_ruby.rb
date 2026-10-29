require_relative "base"
require_relative "ruby_helpers"
require_relative "sorbet_helpers"

module Schematrix
  module Generators
    module Templates
      # Rendering logic for the Sorbet Ruby generator
      class SorbetRuby < Base
        include RubyHelpers
        include SorbetHelpers

        # Slot terms that cannot answer .nil? under typed: strict:
        # T.anything admits no calls (7003) and the null-only,
        # noreturn and disjoint T.all terms make the to_h presence
        # guard statically dead (7006). Those slots type as
        # T.untyped, which admits the guard and stays honest about
        # the runtime values from_h passes.
        UNTYPABLE_SLOT_TYPES = %w[
          T.anything
          NilClass
          T.noreturn
          T.nilable(NilClass)
          T.nilable(T.noreturn)
        ].freeze

        private

        # The generated Sorbet Maybe is sealed, so the to_h case over
        # Present and Absent exhausts and T.absurd checks it.
        def exhaustive_maybe_dump? = @maybe.nil?

        # from_h reads T.untyped document values, and a generic
        # constructor applied to an untyped argument widens to
        # T.anything, which no covariant Maybe accepts; erase the
        # loaded slot back to untyped so it assigns where it must.
        def maybe_loaded(expression, _name)
          "T.unsafe(#{expression})"
        end

        def slot_type(type)
          return "T.untyped" if UNTYPABLE_SLOT_TYPES.include?(type)
          return "T.untyped" if type.start_with?("T.all(", "T.nilable(T.all(")

          type
        end

        def property_type_of(path, name, schema)
          slot_type(super)
        end

        # typed: strict ivars carry a T.let, and freeze lands inside
        # it so the assignment stays typed.
        def immutable_catch_all_assignment
          "@_extra = T.let(_extra.freeze, T::Hash[String, #{
            sorbet_additional_properties_type
          }])"
        end

        def sorbet_attr_accessor(path, name, property)
          type = property_type_of(path, name, property)
          reader = <<~RUBY
            sig { returns(
              #{type}
            ) }
            attr_reader :#{name}
          RUBY
          return reader if immutable?

          <<~RUBY
            sig { returns(
              #{type}
            ) }
            attr_accessor :#{name}
          RUBY
        end

        # Bodies call property readers on the other side; T.anything
        # admits no calls, so the parameter types as T.untyped here.
        def sorbet_equality_signature
          "sig { params(other: T.untyped).returns(T::Boolean) }"
        end

        # The constant carries type annotations in typed: strict
        # files: an unannotated constant fails srb tc.
        def original_keys_constant
          return "" if @property_keys.empty?

          pairs =
            @property_keys.map do |original, name|
              "  #{original.inspect} => #{name.inspect}"
            end
          "ORIGINAL_KEYS = T.let(\n{#{pairs.join(",\n")}\n}.freeze, " \
            "T::Hash[String, Symbol])"
        end

        # Bodies read slots out of the document hash and call methods
        # and feed typed kwargs with the results; T.untyped admits
        # those calls where T.anything rejects them.
        def sorbet_from_h_signature
          [
            "sig do",
            "  params(hash: T::Hash[String, T.untyped])",
            "    .returns(#{own_class_name})",
            "end",
          ].join("\n")
        end

        def sorbet_to_h_signature
          "sig { returns(T::Hash[String, T.untyped]) }"
        end

        # The coercion plumbing dispatches on runtime classes before
        # its results reach typed kwargs; only T.untyped checks along
        # that whole path.
        def sorbet_coercion_signature
          "sig { params(value: T.untyped).returns(T.untyped) }"
        end

        def sorbet_coercion_helper_signature
          "sig { params(value: T.untyped, klass: T.untyped).returns(" \
            "T.untyped) }"
        end

        def sorbet_spec_helper_signature
          "sig { params(value: T.untyped, spec: T.untyped).returns(" \
            "T.untyped) }"
        end
      end
    end
  end
end
