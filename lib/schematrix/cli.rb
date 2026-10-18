require "tty-option"

require_relative "generators/base"

module Schematrix
  # Command line tooling for the library
  class CLI
    include TTY::Option

    usage do
      program "schematrix"

      command "gen"

      desc "Generate code matching a JSON Schema"

      example "Produce plain Ruby code for the given schema",
              "  $ schematrix gen -g plain_ruby -m MyModule " \
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
          log_level = [params[:verbose].count(&:itself), 3].min
          config.level = %i[error warn info debug][log_level]
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
          names = unknown.to_a.join(", ")
          Schematrix.logger&.warn "Unknown generators: #{names}"
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
        # If only one output dir specified, we use it for every generator
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
            .filter_map do |(output_dir, name)|
              GENERATORS[name]&.new(output_dir, module_name, format: true)
            end

        Schematrix.generate(
          input_files:,
          generators:,
          closed_shapes: params[:closed_shapes],
        )
      end
    rescue StandardError => e
      Schematrix.logger&.fatal "Error: ", e
      exit 1
    end
  end
end
