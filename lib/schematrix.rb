require 'tty-logger'

require_relative 'schematrix/visitor'
require_relative 'schematrix/generators/base'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  VERSION = '0.1.0'

  GENERATORS = {
    'plain_ruby' => Generators::PlainRuby,
    'rbs' => Generators::Rbs,
    'sorbet_ruby' => Generators::SorbetRuby,
    'rbi' => Generators::Rbi
  }.freeze

  class << self
    attr_accessor :logger
  end

  def self.generate(
    json,
    generators:,
    input_file:,
    module_name:,
    output_dirs:
  )
    title = json['title']
    schema = Visitor.new.compile(title, json)

    instances = output_dirs.zip(generators).map do |(output_dir, name)|
      GENERATORS[name]&.new(
        output_dir,
        module_name
      )
    end.compact

    schema.each do |path, node|
      logger&.info "Writing #{input_file}#/#{path}"
      instances.each do |generator|
        generator.write(path, node)
      end
    end
  end
end
