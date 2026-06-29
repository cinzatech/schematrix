module Schematrix
  module Output
    # Common functions for Ruby class name and file handling
    module RubyHelpers
      def class_name_from_path(path)
        return pascal_case(@schema_title) if path.nil? || path.empty?

        pascal_case([@schema_title, path].join('/'))
      end

      # For a nested object property the class is generated in a separate file,
      # so we reference it by its derived class name (relative to the enclosing
      # module).
      def nested_class_ref(path, name)
        nested_path = [path, name].reject(&:empty?).join('/')
        class_name_from_path(nested_path)
      end

      def documentation_comment(schema)
        description = schema.description

        return '' if description.nil?

        "# #{description}"
      end

      def constructor_arguments(properties)
        properties.map do |name, schema|
          next "#{name}: #{schema.default.inspect}" unless schema.default.nil?
          next "#{name}: #{nil.inspect}" unless schema.required

          "#{name}:"
        end.join(', ')
      end

      def constructor_assignments(properties)
        properties.map do |name, _schema|
          "@#{name} = #{name}"
        end.join("\n")
      end

      def pascal_case(string)
        string
          .to_s
          .gsub('/', '::')
          .gsub(/\s*::\s*([a-zA-Z\d])/) { "::#{::Regexp.last_match(1).upcase}" }
          .gsub(/(?:^|[\s_-]+)([a-zA-Z\d])/) { ::Regexp.last_match(1).upcase }
      end

      def underscore(string)
        string
          .to_s
          .gsub('::', '/')
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end
    end
  end
end
