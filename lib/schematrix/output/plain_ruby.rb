require 'fileutils'
require 'syntax_tree'

require_relative 'ruby_helpers'

module Schematrix
  module Output
    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby
      include RubyHelpers

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
            #{documentation_comment(object)}
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
    end
  end
end
