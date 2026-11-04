require_relative "sorbet_helpers"

module Schematrix
  module Generators
    module Templates
      # The Sorbet signatures of the DSL builders, shared by the
      # inline format and the RBI one. Setters return self, so
      # chains check; object-shaped slots bind the block to the child
      # builder module, which is what instance_exec does at runtime;
      # mixed slots admit anything in value position, because hash
      # literals are a legal spelling of their object term. The
      # document hash types as T::Hash[String, T.untyped]: builders
      # call <<, concat and merge on their slot reads, and T.untyped
      # is the only value type that accepts every call.
      module DslSorbetSigs
        include SorbetHelpers

        private

        def enum_serialization_expression(klass, value)
          <<~RUBY.strip
            begin
              enum_value = T.let(#{value}, T.anything)
              case enum_value
              when #{klass}
                #{klass}.coerce(enum_value)
              else
                enum_value
              end
            end
          RUBY
        end

        # The document hash is declared where it is first read: a
        # module has no initializer, and typed: strict accepts an
        # instance variable declared nilable inside its own ||=. A
        # read of an initialized hash assigns nothing, so a frozen
        # builder can still answer to_h.
        def fields_method
          <<~RUBY
            def dsl_fields
              @dsl_fields ||= T.let({}, T.nilable(T::Hash[String, T.untyped]))
            end
          RUBY
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
            "  params(block: #{block_type(absolute_own_name)})",
            "    .returns(T::Hash[String, T.untyped])",
            "end",
          ].join("\n")
        end

        def fields_signature
          "sig { returns(T::Hash[String, T.untyped]) }"
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
              "params(key: String, block: #{
                block_type(absolute_builder(extra_builder_term))
              })."
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
            "params(block: #{
              block_type(absolute_builder(property_builder_term(name)))
            })."
          when :array_scalars
            "params(values: #{setter_value_type(name, kind, schema)})."
          when :array_objects
            "params(block: #{
              block_type(absolute_builder(element_builder_term(name)))
            })."
          when :mixed_array
            "params(values: #{untyped}, block: #{
              nilable_block_type(absolute_builder(element_builder_term(name)))
            })."
          when :map_scalars
            "params(key: String, value: #{
              setter_value_type(name, kind, schema)
            })."
          when :map_objects
            "params(key: String, block: #{
              block_type(absolute_builder(map_builder_term(name)))
            })."
          when :mixed_value
            "params(value: #{untyped}, block: #{
              nilable_block_type(absolute_builder(property_builder_term(name)))
            })."
          end
        end

        # The block runs on the named builder, as instance_exec does.
        # The name is absolute: sig blocks evaluate lazily inside the
        # module, where a relative name can hit the nested Builder
        # class.
        def block_type(klass)
          "T.proc.bind(#{klass}).void"
        end

        # Mixed setters branch on the block's presence, so their
        # signature declares it nilable and the branch stays
        # reachable.
        def nilable_block_type(klass)
          "T.nilable(T.proc.bind(#{klass}).void)"
        end
      end
    end
  end
end
