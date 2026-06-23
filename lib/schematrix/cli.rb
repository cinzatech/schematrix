require 'yaml'
require 'tty-option'

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

    option :module do
      required
      short '-m'
      long '--module string'
      desc 'Module where the output code will be placed'
    end

    option :output do
      optional
      short '-o'
      long '--output string'
      desc 'Directory where the output will be written'
      default 'generated'
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
        config.level = %i[error warn info debug][params[:verbose].count(&:itself)] || :error
      end

      if params[:help]
        print help
      elsif params.errors.any?
        puts params.errors.summary
        exit 1
      else
        Schematrix.logger&.debug "CLI arguments: \n", params.to_h.pretty_inspect

        input_files = Array(params[:input])
        module_name = params[:module]
        output_dir = params[:output] || 'generated'
        generators = Set.new(params[:generators])
        unknown = generators - Set['plain_ruby']
        Schematrix.logger&.warn "Unknown generators: #{unknown.to_a.join(', ')}" unless unknown.empty?

        input_files.each do |input_file|
          content = File.read(input_file)
          schema = YAML.safe_load(content)
          Schematrix.generate(
            schema,
            generators:,
            input_file:,
            module_name:,
            output_dir:
          )
        end
      end
    rescue StandardError => e
      Schematrix.logger&.fatal 'Error: ', e
      exit 1
    end
  end
end
