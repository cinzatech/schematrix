require 'tty-logger'

require_relative 'schematrix/visitor'
require_relative 'schematrix/output/plain_ruby'

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
    output_dir:
  )
    schema = Visitor.new.compile(json)

    instances = []
    if generators.include?('plain_ruby')
      instances.push Output::PlainRuby.new(
        output_dir,
        module_name,
        json['title']
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
