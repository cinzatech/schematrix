require 'uri'

module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling
    module Resolver
      # Passing a series of path parts to this method will return the qualified
      # class name corresponding to that path.
      # Example: 'foo/bar', 'baz' => Title::Foo::Bar::Baz
      # Empty parts are removed. 'properties' also removed.
      def class_name_from_path(uri, *path)
        file = File.basename(uri.path).split('.').first
        nested_path = [file, *uri.fragment.split('/'), *path].compact.reject(&:empty?).reject do
          ['properties', '$defs'].include?(_1)
        end.join('/')

        pascal_case(nested_path)
      end

      private

      def pascal_case(string)
        string
          .to_s
          .gsub('/', '::')
          .gsub(/\s*::\s*([a-zA-Z\d])/) { "::#{::Regexp.last_match(1).upcase}" }
          .gsub(/(?:^|[\s_-]+)([a-zA-Z\d])/) { ::Regexp.last_match(1).upcase }
      end
    end
  end
end
