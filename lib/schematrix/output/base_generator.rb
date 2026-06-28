require 'erb'
require 'fileutils'
require 'syntax_tree'

require_relative 'ruby_helpers'

module Schematrix
  module Output
    # Base class for all output generators. Subclasses provide an ERB template
    # and, optionally, override helper methods to produce different output
    # formats.
    class BaseGenerator
      include RubyHelpers

      def initialize(output_dir, module_name, schema_title, format: true)
        @output_dir = output_dir
        @module_name = module_name
        @schema_title = schema_title
        @format = format
      end

      def write(path, object)
        code = transform(path, object)

        filename = "#{underscore(class_name_from_path(path))}#{file_extension}"
        file_path = File.join(@output_dir, filename)
        FileUtils.mkdir_p(File.dirname(file_path))

        File.write(file_path, code)
      end

      def transform(path, object)
        setup_template_vars(path, object)
        code = render_template
        format_code(code)
      end

      private

      def setup_template_vars(path, object)
        @path = path
        @object = object
        @class_name = class_name_from_path(path)
        @properties = object.properties.transform_keys do |key|
          underscore(key)
        end
        @additional_properties = object.additional_properties
      end

      def render_template
        template_file = File.join(File.dirname(__FILE__), 'templates', template_name)
        template = ERB.new(File.read(template_file), trim_mode: '-')
        template.result(binding)
      end

      def template_name
        raise NotImplementedError, "#{self.class} must implement #template_name"
      end

      def file_extension
        raise NotImplementedError, "#{self.class} must implement #file_extension"
      end

      def format_code(code)
        return SyntaxTree.format(code) if @format

        code
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
    end
  end
end
