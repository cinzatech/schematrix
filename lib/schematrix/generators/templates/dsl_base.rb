require_relative "base"
require_relative "coercions"
require_relative "type_composer"

module Schematrix
  module Generators
    module Templates
      # Base class for the DSL generator templates: builders whose
      # methods define an instance of the schema through plain method
      # calls. Holds the classification of every property into a
      # setter form and the bodies those forms render to; the
      # notation modules add signatures where the output carries
      # them.
      #
      # The builder runtime is one hash. Every setter writes the
      # property's original key into it, nested slots build through
      # their own builder classes, and to_h hands the hash out. No
      # defaults apply and nothing validates, so a document built at
      # runtime holds exactly what the DSL source declared; the parse
      # contract (docs/dsl.md) reconstructs the same hash statically.
      class DslBase < Base
        include Coercions
        include TypeComposer

        # The argument list each setter form renders.
        SETTER_PARAMS = {
          array_scalars: "*values",
          array_objects: "&block",
          map_scalars: "key, value",
          map_objects: "key, &block",
          mixed_array: "*values, &block",
          mixed_value: "value = nil, &block",
          object: "&block",
          scalar: "value",
        }.freeze

        private

        # The injected leading Dsl segment is the DSL namespace, not
        # a schema-owned class: it always opens as a module. A later
        # segment named Dsl is schema property provenance and stays
        # a class.
        def container_segment?(segment, index)
          super || (index.zero? && segment == "Dsl")
        end

        # The original-name key map the builder carries, the same
        # contract the data classes use: the mapping a parser reads
        # to turn method names back into document keys.
        def original_keys_constant
          return "" if @property_keys.empty?

          pairs =
            @property_keys.map do |original, name|
              "  #{original.inspect} => #{name.inspect}"
            end
          "ORIGINAL_KEYS = {\n#{pairs.join(",\n")}\n}.freeze"
        end

        def original_key_of(name)
          @property_keys.to_h.key(name.to_sym)
        end

        # The entry point: builds a fresh builder, hands it to the
        # block, and returns the document.
        def build_method
          <<~RUBY
            def self.build(&block)
              builder = new
              yield builder
              builder.to_h
            end
          RUBY
        end

        def initialize_method
          <<~RUBY
            def initialize
              #{fields_assignment}
            end
          RUBY
        end

        def fields_assignment
          "@fields = {}"
        end

        def to_h_method
          <<~RUBY
            def to_h
              @fields.dup
            end
          RUBY
        end

        # Every property setter in declaration order. `sigged` pairs
        # each method with its signature; `stub` renders signature
        # files' empty bodies.
        def setter_methods(sigged: false, stub: false)
          return [] if @properties.nil?

          @properties.filter_map do |name, schema|
            kind = setter_kind(name, schema)
            method = setter_method(name, kind, stub:)
            next method unless sigged

            "#{setter_signature(name, kind)}\n#{method}"
          end
        end

        # The DSL form a property takes, derived from the compiled
        # record the same way the coercion plans are: maps first,
        # then arrays by their element, then the first class-shaped
        # term decides between the object and the scalar forms.
        def setter_kind(name, schema)
          return map_kind(name, schema) if schema.map_shaped?
          return array_kind(name, schema) if schema.type.include?(TYPE_ARRAY)

          slot = "properties/#{name}"
          term = class_term(@path, slot, schema)
          if term && declared_scalar_term?(@path, slot, schema)
            return :mixed_value
          end
          return :object if term

          :scalar
        end

        def map_kind(name, schema)
          slot = nested_locator(@path, name)
          term =
            class_term(
              slot,
              "additionalProperties",
              schema.additional_properties,
            )
          term ? :map_objects : :map_scalars
        end

        def array_kind(name, schema)
          term = element_class_term(@path, name, schema)
          return :array_scalars if term.nil?
          return :mixed_array if element_literal_term?(name, schema)

          :array_objects
        end

        # Whether the element of an array slot admits non-class
        # values: an open tail, a declared scalar type, or a scalar
        # variant branch.
        def element_literal_term?(name, schema)
          nested = nested_locator(@path, name)
          return true if schema.items.nil?
          return true if declared_scalar_term?(nested, "items", schema.items)

          schema.prefix_items.any? do |item|
            declared_scalar_term?(nested, "prefixItems", item)
          end
        end

        # Whether the schema declares at least one non-object term,
        # directly or through a variant branch. Untyped records do
        # not count: a pure reference has to classify as an object,
        # not as mixed.
        def declared_scalar_term?(path, name, schema)
          return false if schema.nil?
          return false if schema.untyped?

          scalars =
            schema.type.reject do |type|
              [TYPE_OBJECT, TYPE_BOTTOM].include?(type)
            end
          return true unless scalars.empty?

          nested = nested_locator(path, name)
          schema.any_of.each_with_index do |variant, index|
            if declared_scalar_term?(nested, "anyOf_#{index}", variant)
              return true
            end
          end
          schema.one_of.each_with_index do |variant, index|
            if declared_scalar_term?(nested, "oneOf_#{index}", variant)
              return true
            end
          end
          false
        end

        # The builder class a slot delegates to, qualified from the
        # output module root through the Dsl namespace so nested
        # declarations can never shadow it.
        def qualified_builder(term)
          "#{@module_name}::Dsl::#{term}"
        end

        def property_builder_term(name)
          class_term(@path, "properties/#{name}", @properties[name])
        end

        def element_builder_term(name)
          element_class_term(@path, "properties/#{name}", @properties[name])
        end

        def map_builder_term(name)
          class_term(
            nested_locator(@path, "properties/#{name}"),
            "additionalProperties",
            @properties[name].additional_properties,
          )
        end

        def extra_builder_term
          class_term(@path, "additionalProperties", @additional_properties)
        end

        def extra_kind
          extra_builder_term ? :extra_objects : :extra_scalars
        end

        # The catch-all setter of an open shape: unknown keys ride
        # under their literal names, values built through the
        # catch-all's builder when it carries a class.
        def extra_method(stub: false)
          kind = extra_kind
          params = kind == :extra_objects ? "key, &block" : "key, value"
          return "def extra(#{params}); end" if stub

          if kind == :extra_objects
            <<~RUBY
              def extra(key, &block)
                @fields[key] = #{qualified_builder(extra_builder_term)}.build(&block)
                self
              end
            RUBY
          else
            <<~RUBY
              def extra(key, value)
                @fields[key] = value
                self
              end
            RUBY
          end
        end

        def setter_method(name, kind, stub: false)
          return "def #{name}(#{SETTER_PARAMS[kind]}); end" if stub

          key = original_key_of(name).inspect
          case kind
          when :scalar
            <<~RUBY
              def #{name}(value)
                @fields[#{key}] = value
                self
              end
            RUBY
          when :object
            <<~RUBY
              def #{name}(&block)
                child = #{qualified_builder(property_builder_term(name))}.build(&block)
                current = @fields[#{key}]
                @fields[#{key}] = current.is_a?(Hash) ? current.merge(child) : child
                self
              end
            RUBY
          when :array_scalars
            <<~RUBY
              def #{name}(*values)
                target = (@fields[#{key}] ||= [])
                target.concat(values)
                self
              end
            RUBY
          when :array_objects
            <<~RUBY
              def #{name}(&block)
                target = (@fields[#{key}] ||= [])
                target << #{qualified_builder(element_builder_term(name))}.build(&block)
                self
              end
            RUBY
          when :mixed_array
            builder = qualified_builder(element_builder_term(name))
            <<~RUBY
              def #{name}(*values, &block)
                target = (@fields[#{key}] ||= [])
                target.concat(values)
                target << #{builder}.build(&block) if block
                self
              end
            RUBY
          when :map_scalars
            <<~RUBY
              def #{name}(key, value)
                target = (@fields[#{key}] ||= {})
                target[key] = value
                self
              end
            RUBY
          when :map_objects
            <<~RUBY
              def #{name}(key, &block)
                target = (@fields[#{key}] ||= {})
                target[key] = #{qualified_builder(map_builder_term(name))}.build(&block)
                self
              end
            RUBY
          when :mixed_value
            builder = qualified_builder(property_builder_term(name))
            <<~RUBY
              def #{name}(value = nil, &block)
                if block
                  child = #{builder}.build(&block)
                  current = @fields[#{key}]
                  @fields[#{key}] = current.is_a?(Hash) ? current.merge(child) : child
                else
                  @fields[#{key}] = value
                end
                self
              end
            RUBY
          end
        end

        # The type of the value argument a setter admits: the bare
        # union of the slot's terms, without the nilable wrap of
        # optional slots. Mixed slots return nothing here: their
        # value argument admits anything, because hash literals are
        # a legal spelling of the object term.
        def setter_value_type(name, kind, schema)
          case kind
          when :scalar
            bare_type(@path, "properties/#{name}", schema)
          when :array_scalars
            array_element_type(
              nested_locator(@path, "properties/#{name}"),
              schema,
            )
          when :map_scalars
            map_value_type(
              nested_locator(@path, name),
              schema.additional_properties,
            )
          when :extra_scalars
            map_value_type(@path, @additional_properties)
          end
        end
      end
    end
  end
end
