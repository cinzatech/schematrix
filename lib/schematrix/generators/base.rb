require 'erb'
require 'fileutils'
require 'syntax_tree'
require 'syntax_tree/rbs'

require_relative 'resolver'
require_relative 'templates/plain_ruby'
require_relative 'templates/rbs'
require_relative 'templates/sorbet_ruby'
require_relative 'templates/rbi'

module Schematrix
  module Generators
    # Base class for all output generators. Subclasses provide an ERB template
    # and, optionally, override helper methods to produce different output
    # formats.
    class Base
      include Resolver

      def initialize(output_dir, module_name, format: true)
        @output_dir = output_dir
        @module_name = module_name
        @format = format
      end

      def write(path, object)
        code = transform(path, object)

        filename = "#{underscore(class_name_from_path(path))}#{self.class.file_extension}"
        file_path = File.join(@output_dir, filename)
        FileUtils.mkdir_p(File.dirname(file_path))

        File.write(file_path, code)
      end

      def transform(path, object)
        code = template(path, object).render(self.class.erb)
        format_code(code)
      end

      def self.erb
        @erb ||= begin
          template_file = File.join(File.dirname(__FILE__), 'templates', template_name)
          ERB.new(File.read(template_file), trim_mode: '-')
        end
      end

      def self.template_class
        raise NotImplementedError, "#{self.class} must implement #template_class"
      end

      def self.template_name
        raise NotImplementedError, "#{self.class} must implement #template_name"
      end

      def self.file_extension
        raise NotImplementedError, "#{self.class} must implement #file_extension"
      end

      private

      def template(path, object)
        self.class.template_class.new(
          module_name: @module_name,
          path:,
          class_name: class_name_from_path(path),
          properties: object.properties.transform_keys do |key|
            underscore(key)
          end,
          additional_properties: object.additional_properties,
          documentation_comment: documentation_comment(object)
        )
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

    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby < Base
      def self.template_name = 'plain_ruby.erb'
      def self.file_extension = '.rb'
      def self.template_class = Templates::PlainRuby
    end

    # Outputs RBS type signatures matching a JSON Schema object
    class Rbs < Base
      def self.template_name = 'rbs.erb'
      def self.file_extension = '.rbs'
      def self.template_class = Templates::Rbs

      private

      def format_code(code) = @format ? SyntaxTree::RBS.format(code) : code
    end

    # Outputs a schema as a mutable Ruby class with inline Sorbet signatures
    class SorbetRuby < Base
      def self.template_name = 'sorbet_ruby.erb'
      def self.file_extension = '.rb'
      def self.template_class = Templates::SorbetRuby
    end

    # Outputs a schema as an RBI sorbet signature file
    class Rbi < Base
      def self.template_name = 'rbi.erb'
      def self.file_extension = '.rbi'
      def self.template_class = Templates::Rbi
    end
  end
end
