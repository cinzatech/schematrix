module Schematrix
  module Generators
    module Templates
      # Abstract base class for templates
      class Base
        include Resolver

        def initialize(
          module_name:,
          path:,
          class_name:,
          properties:,
          additional_properties:,
          documentation_comment:
        )
          @module_name = module_name
          @path = path
          @class_name = class_name
          @properties = properties
          @additional_properties = additional_properties
          @documentation_comment = documentation_comment
        end

        def render(erb)
          erb.result(binding)
        end

        private

        # The declaration lines down to the class: one module line per
        # namespace segment, then the class. Nested form rather than
        # the compound `class A::B`, which requires the parent
        # constant to already exist when the file loads; nested
        # declarations make every generated file load in any order.
        # The documentation comment documents the class, so it sits
        # directly above the class line.
        def declaration_open
          segments = @class_name.split("::")
          klass = segments.pop
          lines = segments.map { |segment| "module #{segment}" }
          unless @documentation_comment.empty?
            lines.concat(@documentation_comment.split("\n"))
          end
          lines << "class #{klass}"
          lines.map { |line| "  #{line}" }.join("\n")
        end

        # One end per declaration opened above.
        def declaration_close
          Array.new(@class_name.split("::").size) { "  end" }.join("\n")
        end
      end
    end
  end
end
