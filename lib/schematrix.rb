require 'tty-logger'

require_relative 'schematrix/version'
require_relative 'schematrix/compiler'

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  class << self
    attr_accessor :logger
  end

  def self.generate(
    generators:,
    input_files:
  )
    objects = Compiler.new.compile(input_files)

    objects.each do |locator, node|
      logger&.info "Writing output for #{locator}"
      generators.each do |generator|
        generator.write(locator, node)
      end
    end
  end
end
