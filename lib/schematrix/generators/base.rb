require "erb"
require "fileutils"
require "syntax_tree"
require "syntax_tree/rbs"

require_relative "resolver"
require_relative "templates/plain_ruby"
require_relative "templates/rbs"
require_relative "templates/sorbet_ruby"
require_relative "templates/rbi"

module Schematrix
  module Generators
    # Base class for all output generators. Subclasses provide an ERB template
    # and, optionally, override helper methods to produce different output
    # formats.
    class Base
      include Resolver

      # Ruby keywords that cannot appear as generated accessor names or
      # keyword arguments; property_name suffixes them with "_".
      RUBY_KEYWORDS = %w[
        BEGIN
        END
        alias
        and
        begin
        break
        case
        class
        def
        defined?
        do
        else
        elsif
        end
        ensure
        false
        for
        if
        in
        module
        next
        nil
        not
        or
        redo
        rescue
        retry
        return
        self
        super
        then
        true
        undef
        unless
        until
        when
        while
        yield
      ].freeze

      def initialize(output_dir, module_name, format: true)
        @output_dir = output_dir
        @module_name = module_name
        @format = format
      end

      # The file this locator's class writes to, without writing it:
      # callers that batch many schemas check every target up front.
      def target_path(locator)
        class_name = class_name_from_path(URI(locator))
        filename = "#{underscore(class_name)}#{self.class.file_extension}"
        File.join(@output_dir, filename)
      end

      def write(locator, object)
        uri = URI(locator)
        class_name = class_name_from_path(uri)
        code = transform(uri, class_name, object)

        file_path = target_path(uri)
        FileUtils.mkdir_p(File.dirname(file_path))

        File.write(file_path, code)
        file_path
      end

      def transform(path, class_name, object)
        code = template(path, class_name, object).render(self.class.erb)

        format_code(code)
      end

      def self.erb
        @erb ||=
          begin
            template_file =
              File.join(File.dirname(__FILE__), "templates", template_name)
            ERB.new(File.read(template_file), trim_mode: "-")
          end
      end

      def self.template_class
        raise NotImplementedError, "#{name} must implement #template_class"
      end

      def self.template_name
        raise NotImplementedError, "#{name} must implement #template_name"
      end

      def self.file_extension
        raise NotImplementedError, "#{name} must implement #file_extension"
      end

      private

      def template(path, class_name, object)
        properties = object&.properties
        property_keys = original_key_map(properties)
        warn_mangled_collisions(class_name, path, property_keys)
        self.class.template_class.new(
          module_name: @module_name,
          path:,
          class_name: class_name,
          properties: properties&.transform_keys { |key| property_name(key) },
          property_keys:,
          additional_properties: object.additional_properties,
          documentation_comment: documentation_comment(object),
        )
      end

      def format_code(code)
        return SyntaxTree.format(code) if @format

        code
      end

      # One comment line per description line: raw newlines inside a
      # description would leak the remaining lines as code.
      def documentation_comment(schema)
        description = schema.description
        return "" if description.nil?

        description.lines.map { |line| "# #{line.chomp}".rstrip }.join("\n")
      end

      def underscore(string)
        string
          .to_s
          .gsub("::", "/")
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end

      # A property name safe to use as a Ruby identifier: snake-cased,
      # the leading "$" of core vocabulary keywords ($id, $ref, ...)
      # stripped, characters identifiers cannot carry replaced with
      # underscores, a leading digit prefixed, and Ruby keywords
      # suffixed with an underscore so generated accessors and keyword
      # arguments stay parseable. Original keys stay reachable through
      # the catch-all accessors.
      def property_name(key)
        name = underscore(key).delete_prefix("$")
        name = name.gsub(/[^a-z0-9_]/, "_")
        name = "_#{name}" if name.match?(/\A\d/)
        name = "_" if name.empty?
        name = "#{name}_" if RUBY_KEYWORDS.include?(name)
        name
      end

      # The original-name key map (D21): original String property
      # name to mangled accessor symbol, the inverse of property_name
      # ($id -> id, if -> if_). Generated classes carry it as the
      # ORIGINAL_KEYS constant so round-tripping inverts the
      # mangling, and from_h uses it to tell known keys from
      # catch-all riders.
      def original_key_map(properties)
        properties&.keys&.map { |key| [key, property_name(key).to_sym] } || []
      end

      # Mangling is not injective: sibling property names can fold to
      # one accessor (foo-bar and foo_bar), where transform_keys keeps
      # the last declaration's schema while ORIGINAL_KEYS, from_h and
      # to_h keep the first original's key. The class still compiles,
      # so the collision warns with the kept key instead of staying
      # silent.
      def warn_mangled_collisions(class_name, path, property_keys)
        property_keys
          .group_by { |_original, mangled| mangled }
          .each do |mangled, pairs|
            next if pairs.size == 1

            originals = pairs.map(&:first)
            Schematrix.logger&.warn(
              "#{class_name}: properties #{originals.inspect} collapse " \
                "onto the accessor #{mangled}; from_h and to_h keep " \
                "#{originals.first.inspect} (#{path})",
            )
          end
      end
    end

    # Outputs a schema as a plain, mutable Ruby class
    class PlainRuby < Base
      def self.template_name = "plain_ruby.erb"
      def self.file_extension = ".rb"
      def self.template_class = Templates::PlainRuby
    end

    # Outputs RBS type signatures matching a JSON Schema object
    class Rbs < Base
      def self.template_name = "rbs.erb"
      def self.file_extension = ".rbs"
      def self.template_class = Templates::Rbs

      private

      def format_code(code) = @format ? SyntaxTree::RBS.format(code) : code
    end

    # Outputs a schema as a mutable Ruby class with inline Sorbet signatures
    class SorbetRuby < Base
      def self.template_name = "sorbet_ruby.erb"
      def self.file_extension = ".rb"
      def self.template_class = Templates::SorbetRuby
    end

    # Outputs a schema as an RBI sorbet signature file
    class Rbi < Base
      def self.template_name = "rbi.erb"
      def self.file_extension = ".rbi"
      def self.template_class = Templates::Rbi
    end
  end

  GENERATORS = {
    "plain_ruby" => Generators::PlainRuby,
    "rbs" => Generators::Rbs,
    "sorbet_ruby" => Generators::SorbetRuby,
    "rbi" => Generators::Rbi,
  }.freeze
end
