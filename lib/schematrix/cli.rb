require "tty-option"

require_relative "generators/base"

module Schematrix
  # Command line tooling for the library
  class CLI
    include TTY::Option

    usage do
      program "schematrix"

      # Subcommand-less interface (as documented in the README): without
      # this, tty-option displays a command derived from the class name
      # and treats any first token as an input file.
      no_command

      desc "Generate code matching a JSON Schema"

      example "Produce plain Ruby code for the given schema",
              "  $ schematrix -g plain_ruby -m MyModule " \
                "-o /output/dir my-json-schema.json"
    end

    argument :input do
      required
      arity one_or_more
    end

    option :generators do
      required
      arity one_or_more
      short "-g"
      long "--generators list"
      convert :list
      desc "Output generators to use, e.g.: plain_ruby, rbs"
    end

    option :output do
      optional
      arity zero_or_more
      short "-o"
      long "--output string"
      desc "Directory where the output will be written"
    end

    option :schema_dir do
      optional
      arity zero_or_more
      long "--schema-dir string"
      desc "Directory where remote schema URIs resolve to local files; " \
             "may be given multiple times, defaults to vendor/schemas"
    end

    option :module do
      required
      short "-m"
      long "--module string"
      desc "Module where the output code will be placed"
    end

    flag :closed_shapes do
      optional
      long "--closed-shapes"
      desc "Treat absent additionalProperties as false: closed classes " \
             "with no catch-all, instead of the spec default"
    end

    flag :verbose do
      optional
      arity zero_or_more
      short "-v"
      long "--verbose"
      desc "Each additional occurrence lowers logger level, " \
             "-vvv for the minimum"
    end

    flag :help do
      short "-h"
      long "--help"
      desc "Print usage"
    end

    def run
      Schematrix.logger =
        TTY::Logger.new do |config|
          verbosity = [params[:verbose].count(&:itself), 2].min
          config.level = %i[warn info debug][verbosity]
        end

      if params[:help]
        print help
      elsif params.errors.any?
        Schematrix.logger&.fatal params.errors.summary
        exit 1
      else
        Schematrix.logger&.debug "CLI arguments: \n", params.to_h.pretty_inspect

        input_files = Array(params[:input])
        module_name = params[:module]

        generator_names = Array(params[:generators]).uniq

        unknown = generator_names - GENERATORS.keys
        unless unknown.empty?
          names = unknown.join(", ")
          Schematrix.logger&.fatal "Unknown generators: #{names}"
          exit 1
        end

        output = Array(params[:output])
        unless [0, 1, generator_names.size].include?(output.size)
          message =
            "The specified amount of output directories " \
              "doesn't match the amount of generators"
          Schematrix.logger&.fatal message
          exit 1
        end
        output << "generated" if output.empty?
        output_dirs =
          (
            if output.size == 1
              Array.new(generator_names.size, output.first)
            else
              output
            end
          )

        generators =
          output_dirs
            .zip(generator_names)
            .map do |(output_dir, name)|
              GENERATORS.fetch(name).new(output_dir, module_name, format: true)
            end

        Schematrix.generate(
          input_files:,
          generators:,
          closed_shapes: params[:closed_shapes],
          schema_dirs: resolved_schema_dirs,
        )
      end
    rescue StandardError => e
      Schematrix.logger&.fatal "Error: ", e
      exit 1
    end

    private

    # vendor/schemas is searched unless the user points elsewhere;
    # explicit directories replace the default, never stack with it
    def resolved_schema_dirs
      schema_dirs = Array(params[:schema_dir])
      schema_dirs = %w[vendor/schemas] if schema_dirs.empty?

      schema_dirs
    end
  end
end
