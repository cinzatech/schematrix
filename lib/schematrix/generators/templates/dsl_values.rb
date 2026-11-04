require_relative "enum_base"

module Schematrix
  module Generators
    module Templates
      # Slot traversal shared by builder serialization and parser contracts.
      module DslValues
        private

        def dsl_value_spec(path, name, schema)
          return if schema.nil? || schema.untyped?

          nested = nested_locator(path, name)
          if schema.map_shaped?
            values =
              dsl_value_spec(
                nested,
                "additionalProperties",
                schema.additional_properties,
              )
            return :map, values
          end
          if schema.enum_class? && @enums == :classes
            type = schema.enum.first.is_a?(String) ? TYPE_STRING : TYPE_INTEGER
            klass = enum_class_name(path, name, schema)
            entry = lookup_scalar_type(type, schema.format)
            return :enum, klass, schema.enum, entry
          end

          specs =
            schema.type.filter_map do |type|
              if type == TYPE_ARRAY
                prefix =
                  schema.prefix_items.each_with_index.map do |item, index|
                    dsl_value_spec(nested, "prefixItems/#{index}", item)
                  end
                tail = dsl_value_spec(nested, "items", schema.items)
                [:array, prefix, tail]
              else
                entry = lookup_scalar_type(type, schema.format)
                [:scalar, type, entry] if entry&.coerces? || entry&.reader
              end
            end
          return specs.first if schema.intersection

          schema.any_of.each_with_index do |variant, index|
            specs << dsl_value_spec(nested, "anyOf_#{index}", variant)
          end
          schema.one_of.each_with_index do |variant, index|
            specs << dsl_value_spec(nested, "oneOf_#{index}", variant)
          end
          specs = specs.compact.uniq
          return if specs.empty?
          return specs.first if specs.size == 1

          conversion_spec(path, name, schema)
          readers = specs.flat_map { |spec| dsl_slot_readers(spec) }.uniq
          if readers.size > 1
            raise CoercionConflictError,
                  "#{nested}: different readers cannot share one DSL value slot"
          end
          [:union, specs]
        end

        def dsl_slot_readers(spec)
          return [] if spec.nil?

          case spec[0]
          when :scalar
            [spec[2].reader].compact
          when :enum
            [spec[3]&.reader].compact
          when :union
            spec[1].flat_map { |sub| dsl_slot_readers(sub) }
          else
            []
          end
        end

        def dsl_property_spec(name)
          dsl_value_spec(@path, "properties/#{name}", @properties.fetch(name))
        end

        def dsl_setter_spec(name, kind)
          schema = @properties.fetch(name)
          if %i[map_scalars map_objects].include?(kind)
            spec =
              dsl_value_spec(
                nested_locator(@path, "properties/#{name}"),
                "additionalProperties",
                schema.additional_properties,
              )
            return spec
          end
          dsl_property_spec(name)
        end

        def dsl_extra_spec
          dsl_value_spec(@path, "additionalProperties", @additional_properties)
        end

        def dsl_serialize(spec, value, depth: 0, offset: "0")
          return value if spec.nil?

          case spec[0]
          when :scalar
            dsl_scalar_serialize(spec[2], value)
          when :enum
            klass = "::#{@module_name}::#{spec[1]}"
            enum_serialization_expression(klass, value)
          when :map
            item = "entry#{depth}"
            converted = dsl_serialize(spec[1], item, depth: depth + 1)
            return value if converted == item

            "(#{value}.is_a?(::Hash) ? " \
              "#{value}.transform_values { |#{item}| #{converted} } : #{value})"
          when :array
            dsl_array_serialize(spec, value, depth:, offset:)
          when :union
            converted =
              spec[1].map do |sub|
                dsl_serialize(sub, "entry#{depth}", depth: depth + 1)
              end
            converted.reject! { |expression| expression == "entry#{depth}" }
            return value if converted.empty?

            body =
              converted.map do |expression|
                "converted#{depth} = (#{expression})\n" \
                  "next converted#{depth} unless " \
                  "converted#{depth}.equal?(entry#{depth})"
              end
            "->(entry#{depth}) { #{body.join("\n")}\n" \
              "entry#{depth} }.call(#{value})"
          end
        end

        def dsl_array_serialize(spec, value, depth:, offset:)
          item = "entry#{depth}"
          index = "index#{depth}"
          prefix =
            spec[1].map { |sub| dsl_serialize(sub, item, depth: depth + 1) }
          tail = dsl_serialize(spec[2], item, depth: depth + 1)
          return value if (prefix + [tail]).all?(item)

          if prefix.empty?
            mapped =
              "(#{value}.is_a?(::Array) ? " \
                "#{value}.map { |#{item}| #{tail} } : #{value})"
            return mapped
          end
          branches =
            prefix.each_with_index.map do |expression, position|
              "when #{position}\n#{expression}"
            end
          "(#{value}.is_a?(::Array) ? " \
            "#{value}.each_with_index.map do |#{item}, #{index}|\n" \
            "case #{offset} + #{index}\n#{branches.join("\n")}\n" \
            "else\n#{tail}\nend\nend : #{value})"
        end

        def enum_serialization_expression(klass, value)
          "#{value}.is_a?(#{klass}) ? #{klass}.coerce(#{value}) : #{value}"
        end

        def dsl_scalar_serialize(entry, value)
          return value unless entry&.coerces?

          if entry.coercer == Coercers::Date
            "(#{value}.is_a?(::Date) ? #{value}.iso8601 : #{value})"
          elsif entry.coercer == Coercers::DateTime
            "(#{value}.is_a?(::Time) ? #{value}.iso8601 : #{value})"
          else
            "::#{entry.coercer.name}.coerce(#{value})"
          end
        end

        def dsl_builtin_requires
          entries =
            (@properties || {}).flat_map do |name, schema|
              dsl_spec_entries(dsl_setter_spec(name, setter_kind(name, schema)))
            end
          entries.concat(dsl_spec_entries(dsl_extra_spec))
          entries
            .filter_map do |entry|
              coercer = entry&.coercer
              if Coercers::BUILTIN.include?(coercer)
                "require #{coercer::GENERATED_REQUIRE.inspect}"
              end
            end
            .uniq
            .join("\n")
        end

        def dsl_spec_entries(spec)
          return [] if spec.nil?

          case spec[0]
          when :scalar
            [spec[2]]
          when :enum
            [spec[3]]
          when :array
            (spec[1] + [spec[2]]).flat_map { |sub| dsl_spec_entries(sub) }
          when :map
            dsl_spec_entries(spec[1])
          when :union
            spec[1].flat_map { |sub| dsl_spec_entries(sub) }
          end
        end

        def dsl_parser_value(spec)
          return "nil" if spec.nil?

          case spec[0]
          when :scalar
            entry = spec[2]
            reader =
              (
                if entry.reader
                  "->(node) { ::#{entry.reader.name}.read(node) }"
                else
                  "nil"
                end
              )
            normalized = dsl_scalar_serialize(entry, "value")
            normalizer =
              normalized == "value" ? "nil" : "->(value) { #{normalized} }"
            "[:value, #{reader}, #{normalizer}, {}]"
          when :enum
            reader = spec[3]&.reader
            reader = reader ? "->(node) { ::#{reader.name}.read(node) }" : "nil"
            members =
              EnumBase
                .fold_members(spec[2])
                .map do |member, raw|
                  value = raw.inspect
                  coercer = spec[3]&.coercer
                  if coercer && !Coercers::BUILTIN.include?(coercer)
                    value =
                      "::#{coercer.name}.coerce(" \
                        "::#{coercer.name}.coerce(#{value}))"
                  end
                  constant = "#{@module_name}::#{spec[1]}::#{member}"
                  "#{constant.inspect} => -> { #{value} }"
                end
            "[:value, #{reader}, nil, {#{members.join(", ")}}]"
          when :map
            "[:map, #{dsl_parser_value(spec[1])}]"
          when :array
            prefix = spec[1].map { |sub| dsl_parser_value(sub) }
            "[:array, [#{prefix.join(", ")}], #{dsl_parser_value(spec[2])}]"
          when :union
            branches = spec[1].map { |sub| dsl_parser_value(sub) }
            "[:union, [#{branches.join(", ")}]]"
          end
        end
      end
    end
  end
end
