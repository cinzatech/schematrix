require 'tty-logger'

require_relative 'schematrix/visitor'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  VERSION = '0.1.0'

  class << self
    attr_accessor :logger
  end

  def self.generate(
    json,
    generators:,
    input_file:
  )
    title = json['title']
    objects = Visitor.new.compile(title, json)

    objects.each do |path, node|
      logger&.info "Writing #{input_file}#/#{path}"
      generators.each do |generator|
        generator.write(path, node)
      end
    end
  end
end
