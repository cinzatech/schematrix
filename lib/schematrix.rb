require 'yaml'
require 'tty-logger'

require_relative 'schematrix/visitor'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  VERSION = '0.1.0'

  class << self
    attr_accessor :logger
  end

  def self.generate(
    generators:,
    input_file:
  )
    content = File.read(input_file)
    schema = YAML.safe_load(content)

    objects = Visitor.new.compile(input_file, schema)

    objects.each do |path, node|
      logger&.info "Writing output for #{path}"
      generators.each do |generator|
        generator.write(path, node)
      end
    end
  end
end
