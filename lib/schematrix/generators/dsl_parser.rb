require_relative "base"
require_relative "templates/dsl_parser"
require_relative "templates/dsl_parser_runtime"

module Schematrix
  module Generators
    # Outputs the instance DSL parser family: one static parser module
    # per compiled object schema under a Parser module level, plus the
    # shared Prism runtime written once per output directory through
    # DslParserSupport. Selecting dsl_parser is all a run needs; no
    # builder or enum code loads at parse time.
    class DslParser < Base
      include DslNaming

      def self.template_name = "dsl_parser.erb"
      def self.template_class = Templates::DslParser
      def self.file_extension = ".rb"

      def class_name_from_path(uri, name = nil)
        super.sub(/\ADsl::/, "Parser::")
      end

      def support_generators
        [DslParserSupport.new(output_dir, module_name, format:, command:)]
      end
    end

    # Run-once companion of DslParser: writes parser/runtime.rb, the
    # embedded walker, and parser/parse_error.rb, the shared error
    # class, into the output directory.
    class DslParserSupport < Base
      def self.run_once? = true
      def self.file_extension = ".rb"
      def self.immutable_supported? = false
      def self.maybe_supported? = false

      def run_once_target_paths
        %w[runtime parse_error].map do |name|
          File.join(output_dir, "parser", "#{name}.rb")
        end
      end

      def write_run_once(_objects)
        FileUtils.mkdir_p(File.join(output_dir, "parser"))
        run_once_render.each do |name, code|
          File.write(File.join(output_dir, "parser", name), code)
        end
      end

      def run_once_render
        runtime = <<~RUBY
          require "prism"

          module #{module_name}
            module Parser
              module Runtime
                #{Templates::DslParserRuntime::BODY}
              end
            end
          end
        RUBY
        error = <<~RUBY
          require_relative "runtime"

          module #{module_name}
            module Parser
              ParseError = Runtime::ParseError
            end
          end
        RUBY
        {
          "runtime.rb" =>
            with_banner(
              format_code(runtime),
              "#{module_name}::Parser::Runtime",
              "module",
            ),
          "parse_error.rb" =>
            with_banner(
              format_code(error),
              "#{module_name}::Parser::ParseError",
              "class",
            ),
        }
      end
    end
  end
end
