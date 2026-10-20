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

        def initialize(
          module_name:,
          path:,
          class_name:,
          properties:,
          additional_properties:,
          documentation_comment:,
          property_keys: []
        )
          @module_name = module_name
          @path = path
          @class_name = class_name
          @properties = properties
          @property_keys = property_keys
          @additional_properties = additional_properties
          @documentation_comment = documentation_comment
        end

        def render(erb)
          erb.result(binding)
        end

        private

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
            segments.map do |segment|
              if container_segment?(segment)
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

        def container_segment?(segment)
          CONTAINER_SEGMENTS.include?(segment)
        end

        def declaration_close
          Array.new(@class_name.split("::").size) { "  end" }.join("\n")
        end
      end
    end
  end
end
