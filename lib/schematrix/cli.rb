require "tty-option"

require_relative "generators"

# Splits a comma-separated option value into its elements. A custom
# conversion instead of the built-in `:list`: tty-option treats every
# option whose conversion name looks list-like as multi-argument and
# consumes all following tokens, which would absorb the positional
# input files when -g is the last option before them. A value with
# nothing but delimiters converts to Undefined, which the parser
# reports as an invalid conversion instead of storing an empty list
# that satisfies the arity check.
TTY::Option::Conversions.convert(:comma) do |value|
  names = value.split(",").map(&:strip).reject(&:empty?)
  next TTY::Option::Const::Undefined if names.empty?

  names
end

module Schematrix
  # The `schematrix` command line interface. Parses ARGV through
  # tty-option and runs Schematrix.generate with the parsed settings.
  # The user-facing manual for every option lives in docs/cli.md.
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

    # Splits comma-separated values at parse time through the :comma
    # conversion; repeated flags accumulate alongside them.
    option :generators do
      required
      arity one_or_more
      short "-g"
      long "--generators list"
      convert :comma
      desc "Output generators to use, e.g.: plain_ruby, auxiliary_files"
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

    option :optionals do
      optional
      long "--optionals string"
      desc "How optional slots type: nilable (the default) or maybe, " \
             "the Maybe type that keeps absent and null apart"
    end

    flag :immutable do
      optional
      long "--immutable"
      desc "Generate data classes as frozen value objects: readers, a " \
             "with copier, and value equality; data generators only"
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

    # Parses nothing itself; call parse first, then run. Prints help
    # when asked, refuses invalid arguments and unknown generator
    # names, pairs output directories with generators (zero `-o` flags
    # mean `generated`, one `-o` is shared by all generators, one per
    # `-g` pairs in flag order), and hands everything to
    # Schematrix.generate. Exits 1 on any failure, with the reason on
    # the fatal log level.
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

        generator_names = Array(params[:generators])

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

        optionals = (params[:optionals] || "nilable").to_sym
        unless %i[nilable maybe].include?(optionals)
          Schematrix.logger&.fatal(
            "Unknown optionals mode: #{params[:optionals]} " \
              "(use nilable or maybe)",
          )
          exit 1
        end

        generators =
          output_dirs
            .zip(generator_names)
            .uniq
            .map do |(output_dir, name)|
              generator_class = GENERATORS.fetch(name)
              generator_class.new(
                output_dir,
                module_name,
                format: true,
                command: "schematrix",
                immutable:
                  params[:immutable] && generator_class.immutable_supported?,
                optionals:,
              )
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
    # explicit directories replace the default, never stack with it.
    def resolved_schema_dirs
      schema_dirs = Array(params[:schema_dir])
      schema_dirs = %w[vendor/schemas] if schema_dirs.empty?

      schema_dirs
    end
  end
end
