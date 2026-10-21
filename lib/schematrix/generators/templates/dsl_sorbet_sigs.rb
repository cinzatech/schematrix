require_relative "sorbet_helpers"

module Schematrix
  module Generators
    module Templates
      # The Sorbet signatures of the DSL builders, shared by the
      # inline format and the RBI one. Setters return self, so
      # chains check; object-shaped slots carry the child builder's
      # class in the block type; mixed slots admit anything in value
      # position, because hash literals are a legal spelling of
      # their object term. The document hash types as
      # T::Hash[String, T.untyped]: builders call <<, concat and
      # merge on their slot reads, and T.untyped is the only value
      # type that accepts every call.
      module DslSorbetSigs
        include SorbetHelpers

        private

        def fields_assignment
          "@fields = T.let({}, T::Hash[String, T.untyped])"
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

        def build_signature
          [
            "sig do",
            "  params(block: #{block_type(own_class_name)})",
            "    .returns(T::Hash[String, T.untyped])",
            "end",
          ].join("\n")
        end

        def initialize_signature
          "sig { void }"
        end

        def to_h_signature
          "sig { returns(T::Hash[String, T.untyped]) }"
        end

        def extra_signature
          params =
            if extra_kind == :extra_scalars
              "params(key: String, value: #{
                setter_value_type(nil, :extra_scalars, nil)
              })."
            else
              "params(key: String, block: #{block_type(extra_builder_term)})."
            end
          "sig { #{params}returns(T.self_type) }"
        end

        def setter_signature(name, kind)
          "sig { #{setter_sig_params(name, kind)}returns(T.self_type) }"
        end

        def setter_sig_params(name, kind)
          schema = @properties[name]
          case kind
          when :scalar
            "params(value: #{setter_value_type(name, kind, schema)})."
          when :object
            "params(block: #{block_type(property_builder_term(name))})."
          when :array_scalars
            "params(values: #{setter_value_type(name, kind, schema)})."
          when :array_objects
            "params(block: #{block_type(element_builder_term(name))})."
          when :mixed_array
            "params(values: #{untyped}, block: #{
              nilable_block_type(element_builder_term(name))
            })."
          when :map_scalars
            "params(key: String, value: #{
              setter_value_type(name, kind, schema)
            })."
          when :map_objects
            "params(key: String, block: #{block_type(map_builder_term(name))})."
          when :mixed_value
            "params(value: #{untyped}, block: #{
              nilable_block_type(property_builder_term(name))
            })."
          end
        end

        def block_type(klass)
          "T.proc.params(arg0: #{klass}).void"
        end

        # Mixed setters branch on the block's presence, so their
        # signature declares it nilable and the branch stays
        # reachable.
        def nilable_block_type(klass)
          "T.nilable(T.proc.params(arg0: #{klass}).void)"
        end
      end
    end
  end
end
