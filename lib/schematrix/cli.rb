require 'yaml'
require 'tty-option'

require_relative 'generators/base'

module Schematrix
  # Command line tooling for the library
  class CLI
    include TTY::Option

    usage do
      program 'schematrix'

      command 'gen'

      desc 'Generate code matching a JSON Schema'

      example 'Produce plain Ruby code for the given schema',
              '  $ schematrix gen -g plain_ruby -m MyModule -o /output/dir my-json-schema.json'
    end

    argument :input do
      required
      arity one_or_more
    end

    option :generators do
      required
      arity one_or_more
      short '-g'
      long '--generators list'
      convert :list
      desc 'Output generators to use, i.e.: plain_ruby, rbs'
    end

    option :output do
      optional
      arity zero_or_more
      short '-o'
      long '--output string'
      desc 'Directory where the output will be written'
    end

    option :module do
      required
      short '-m'
      long '--module string'
      desc 'Module where the output code will be placed'
    end

    flag :verbose do
      optional
      arity zero_or_more
      short '-v'
      long '--verbose'
      desc 'Each additional occurrence lowers logger level, -vvv for the minimum'
    end

    flag :help do
      short '-h'
      long '--help'
      desc 'Print usage'
    end

    def run
      Schematrix.logger = TTY::Logger.new do |config|
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

        unknown = generators - GENERATORS.keys
        Schematrix.logger&.warn "Unknown generators: #{unknown.to_a.join(', ')}" unless unknown.empty?

        output = Array(params[:output])
        unless [0, 1, generators.size].include?(output.size)
          Schematrix.logger&.fatal "The specified amount of output directories doesn't match the amount of generators"
          exit 1
        end
        output << 'generated' if output.empty?
        # If only one output dir specified, we use it for every generator
        output_dirs = output.size == 1 ? Array.new(generators.size, output.first) : output

        generators = output_dirs.zip(generator_names).map do |(output_dir, name)|
          GENERATORS[name]&.new(
            output_dir,
            module_name
          )
        end.compact

        input_files.each do |input_file|
          content = File.read(input_file)
          schema = YAML.safe_load(content)
          Schematrix.generate(
            schema,
            generators:,
            input_file:
          )
        end
      end
    rescue StandardError => e
      Schematrix.logger&.fatal 'Error: ', e
      exit 1
    end
  end
end
