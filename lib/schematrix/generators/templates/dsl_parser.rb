require_relative "dsl_base"
require "pathname"

module Schematrix
  module Generators
    module Templates
      # Outputs a static Prism parser for one builder: the parse contract
      # of the schema as data, plus parse and parse_file entry points.
      # Declares the same nesting as the builder module tree, one level
      # up at Parser instead of Dsl, and requires the shared runtime and
      # parse error files the dsl_parser generator writes alongside it.
      class DslParser < DslBase
        private

        def parser_contract
          setters =
            (@properties || {}).map do |name, schema|
              kind = setter_kind(name, schema)
              child =
                case kind
                when :object, :mixed_value
                  property_builder_term(name)
                when :array_objects, :mixed_array
                  element_builder_term(name)
                when :map_objects
                  map_builder_term(name)
                end
              [
                name,
                parser_setter(
                  kind,
                  original_key_of(name),
                  dsl_setter_spec(name, kind),
                  child,
                ),
              ]
            end
          if @additional_properties
            setters << [
              "extra",
              parser_setter(
                extra_kind,
                nil,
                dsl_extra_spec,
                extra_builder_term,
              ),
            ]
          end
          pairs =
            setters.map do |name, descriptor|
              "#{name.inspect} => #{descriptor}"
            end
          builder =
            "#{@module_name}::Dsl::#{@class_name.delete_prefix("Parser::")}"
          "{builder: #{builder.inspect}, " \
            "setters: {#{pairs.join(",\n")}}}.freeze"
        end

        def parser_setter(kind, key, spec, child)
          child =
            (
              if child
                "-> { ::#{@module_name}::Parser::#{child}::CONTRACT }"
              else
                "nil"
              end
            )
          "{kind: #{kind.inspect}, key: #{key.inspect}, " \
            "value: #{dsl_parser_value(spec)}, child: #{child}}"
        end

        def parser_requires
          %w[Parser::Runtime Parser::ParseError]
            .map do |target|
              "require_relative #{parser_relative_path(target).inspect}"
            end
            .join("\n")
        end

        def parser_child_requires
          children =
            (@properties || {}).filter_map do |name, schema|
              case setter_kind(name, schema)
              when :object, :mixed_value
                property_builder_term(name)
              when :array_objects, :mixed_array
                element_builder_term(name)
              when :map_objects
                map_builder_term(name)
              end
            end
          children << extra_builder_term if @additional_properties
          children
            .compact
            .uniq
            .filter_map do |child|
              target = "Parser::#{child}"
              next if target == @class_name

              "require_relative #{parser_relative_path(target).inspect}"
            end
            .join("\n")
        end

        def parser_relative_path(target)
          directory = Pathname.new(File.dirname(underscore(@class_name)))
          Pathname.new(underscore(target)).relative_path_from(directory).to_s
        end
      end
    end
  end
end
