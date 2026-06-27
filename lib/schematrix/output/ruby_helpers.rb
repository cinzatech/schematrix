module Schematrix
  module Output
    # Common functions for Ruby class name and file handling
    module RubyHelpers
      def class_name_from_path(path)
        return pascal_case(@schema_title) if path.nil? || path.empty?

        pascal_case([@schema_title, path].join('/'))
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
