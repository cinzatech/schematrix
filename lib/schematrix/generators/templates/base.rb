module Schematrix
  module Generators
    module Templates
      # Abstract base class for templates
      class Base
        include Resolver

        # Namespace segments that come from a container keyword
        # (properties, $defs) rather than a schema that owns its own
        # class file.
        CONTAINER_SEGMENTS = %w[Props Defs].freeze

        # Holds everything an ERB template reads: the module
        # namespace, the schema path, the class name, the properties
        # keyed by mangled name, the original-name key map, the
        # catch-all schema, and the description comment.
        def initialize(
          module_name:,
          path:,
          class_name:,
          properties:,
          additional_properties:,
          documentation_comment:,
          property_keys: [],
          scalar_types: Schematrix::BUILTIN_SCALAR_TYPES,
          immutable: false
        )
          @module_name = module_name
          @path = path
          @class_name = class_name
          @properties = properties
          @property_keys = property_keys
          @additional_properties = additional_properties
          @documentation_comment = documentation_comment
          @scalar_types = scalar_types
          @immutable = immutable
        end

        # The merged [type, format] rendering table the type algebra
        # and the coercion plans read. Generators pass the table their
        # `scalar_types:` option produced; the default is the built in
        # one.
        attr_reader :scalar_types

        # The rendering entry of a [type, format] pair, most specific
        # first: the exact pair, then the bare type. nil when neither
        # is in the table, so an unknown format renders as its bare
        # type and an unknown type as unconstrained.
        def lookup_scalar_type(type, format = nil)
          scalar_types[[type, format]] || scalar_types[[type, nil]]
        end

        # Evaluates the ERB with this template's binding: the template
        # calls the helper methods below and in the included modules.
        def render(erb)
          erb.result(binding)
        end

        private

        # Whether the class renders as a frozen value object: readers
        # instead of accessors, the catch-all as a constructor
        # keyword, a with copier, and value equality.
        def immutable? = @immutable

        # The class's own name, without the module path: the name a
        # self-referencing signature renders (Schema, Child).
        def own_class_name
          @class_name.split("::").last
        end

        # The declaration lines down to the class: one line per
        # namespace segment, then the class. Container segments
        # (Props/Defs) open as modules, every other segment as a
        # class: the document root and property-named intermediates
        # are classes in their own files, and Ruby refuses to reopen
        # a class with the module keyword (or a module with class),
        # so the kind has to match. This is what actually makes
        # every generated file load in any order.
        def declaration_open
          segments = @class_name.split("::")
          klass = segments.pop
          lines =
            segments.each_with_index.map do |segment, index|
              if container_segment?(segment, index)
                "module #{segment}"
              else
                "class #{segment}"
              end
            end
          unless @documentation_comment.empty?
            lines.concat(@documentation_comment.split("\n"))
          end
          lines << "class #{klass}"
          lines.map { |line| "  #{line}" }.join("\n")
        end

        # Whether a name segment is a container level (Props/Defs)
        # and therefore opens as a module. The position indexes the
        # declared segments, so generators that inject their own
        # leading segment can force just that one (the DSL builders'
        # Dsl level is a namespace, never a schema-owned class).
        def container_segment?(segment, _index)
          CONTAINER_SEGMENTS.include?(segment)
        end

        # One `end` per nesting level of the class declaration.
        def declaration_close
          Array.new(@class_name.split("::").size) { "  end" }.join("\n")
        end
      end
    end
  end
end
