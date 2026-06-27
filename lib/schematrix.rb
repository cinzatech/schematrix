require 'tty-logger'

require_relative 'schematrix/visitor'
require_relative 'schematrix/output/plain_ruby'
require_relative 'schematrix/output/rbs'
require_relative 'schematrix/output/sorbet_ruby'
require_relative 'schematrix/output/rbi'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  VERSION = '0.1.0'

  GENERATORS = {
    'plain_ruby' => Output::PlainRuby,
    'rbs' => Output::Rbs,
    'sorbet_ruby' => Output::SorbetRuby,
    'rbi' => Output::Rbi
  }.freeze

  class << self
    attr_accessor :logger
  end

  def self.generate(
    json,
    generators:,
    input_file:,
    module_name:,
    output_dirs:,
    strict_mode:
  )
    schema = Visitor.new(strict_mode:).compile(json)
    title = json['title']

    instances = output_dirs.zip(generators).map do |(output_dir, name)|
      GENERATORS[name].new(
        output_dir,
        module_name,
        title
      )
    end

    schema.each do |path, node|
      logger&.info "Writing #{input_file}#/#{path}"
      instances.each do |generator|
        generator.write(path, node)
      end
    end
  end
end
