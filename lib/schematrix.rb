require 'tty-logger'

require_relative 'schematrix/visitor'
require_relative 'schematrix/output/plain_ruby'
require_relative 'schematrix/output/rbs'
require_relative 'schematrix/output/sorbet_ruby'
require_relative 'schematrix/output/rbi'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  VERSION = '0.1.0'

  class << self
    attr_accessor :logger
  end

  def self.generate(
    json,
    generators:,
    input_file:,
    module_name:,
    output_dir:,
    strict_mode:
  )
    schema = Visitor.new(strict_mode:).compile(json)
    title = json['title']

    instances = []
    if generators.include?('plain_ruby')
      instances.push Output::PlainRuby.new(
        output_dir,
        module_name,
        title
      )
    end
    if generators.include?('rbs')
      instances.push Output::Rbs.new(
        output_dir,
        module_name,
        title
      )
    end
    if generators.include?('sorbet_ruby')
      instances.push Output::SorbetRuby.new(
        output_dir,
        module_name,
        title
      )
    end
    if generators.include?('rbi')
      instances.push Output::Rbi.new(
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
