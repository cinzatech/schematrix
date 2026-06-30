module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling
    module Resolver
      # Passing a series of path parts to this method will return the qualified
      # class name corresponding to that path. The @schema_title is always
      # appended at the beginning.
      # Example: 'title' + 'foo/bar', 'baz' => Title::Foo::Bar::Baz
      # Empty paths are removed.
      def class_name_from_path(*path)
        nested_path =
          [@schema_title]
          .concat(path)
          .compact
          .reject(&:empty?)
          .join('/')

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
