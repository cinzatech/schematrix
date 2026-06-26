require 'fileutils'
require 'syntax_tree'

module Schematrix
  module Output
    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby
      def initialize(output_dir, module_name, schema_title, format: true)
        @output_dir = output_dir
        @module_name = module_name
        @schema_title = schema_title
        @format = format
      end

      def write(path, object)
        code = transform(path, object)

        filename = "#{underscore(class_name_from_path(path))}.rb"
        file_path = File.join(@output_dir, filename)
        FileUtils.mkdir_p(File.dirname(file_path))

        File.write(file_path, code)
      end

      def transform(path, object)
        class_name = class_name_from_path(path)
        properties = object.properties.transform_keys { |key| underscore(key) }
        attr_accessors = properties.keys.map(&:to_sym).map(&:inspect)

        code = <<~RUBY
          module #{@module_name}
            #{class_documentation_comment(object)}
            class #{class_name}
              def initialize(
                #{constructor_arguments(properties)}
              )
                #{constructor_assignments(properties)}
              end

              attr_accessor #{attr_accessors.join(', ')}
            end
          end
        RUBY

        return SyntaxTree.format(code) if @format

        code
      end

      private

      def class_name_from_path(path)
        return pascal_case(@schema_title) if path.nil? || path.empty?

        pascal_case([@schema_title, path].join('/'))
      end

      def class_documentation_comment(schema)
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
