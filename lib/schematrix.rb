require "tty-logger"

require_relative "schematrix/version"
require_relative "schematrix/compiler"

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  class << self
    attr_accessor :logger
  end

  # closed_shapes: true makes absent additionalProperties behave as
  # false (closed classes) instead of the spec default (D12).
  # schema_dirs: directories that remote schema URIs resolve through
  # (D16), searched in order.
  def self.generate(
    generators:,
    input_files:,
    closed_shapes: false,
    schema_dirs: []
  )
    store = DocumentStore.new(schema_dirs:)
    objects = Compiler.new(store:, closed_shapes:).compile(input_files)

    objects.each do |locator, node|
      logger&.info "Writing output for #{locator}"
      generators.each { |generator| generator.write(locator, node) }
    end
  end
end
