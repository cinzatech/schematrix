require "tty-logger"

require_relative "schematrix/version"
require_relative "schematrix/compiler"

# Generates Ruby code and RBS signatures from JSON Schema definition
module Schematrix
  class << self
    attr_accessor :logger
  end

  # Raised when two schemas, or two generators sharing a file
  # extension in one directory, map to the same output file.
  # Refusing beats silently overwriting one class with another.
  class OutputCollisionError < StandardError
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

    assert_distinct_targets(generators, objects)

    objects.each do |locator, node|
      logger&.info "Writing output for #{locator}"
      generators.each { |generator| generator.write(locator, node) }
    end
  end

  # Every generator and locator must land on its own file. Container
  # provenance is encoded in class names (Props/Defs module levels),
  # so distinct locators almost always map to distinct files; this
  # catches what folding cannot (two input files with the same
  # basename, property names that normalize to the same identifier,
  # two same-extension generators into one directory) before any
  # file is written.
  def self.assert_distinct_targets(generators, objects)
    claimed = {}
    generators.each do |generator|
      objects.each_key do |locator|
        path = generator.target_path(locator)
        if claimed.key?(path)
          raise OutputCollisionError,
                "#{generator.class} writes #{locator} to #{path}, " \
                  "already claimed by #{claimed[path]}"
        end

        claimed[path] = locator
      end
    end
  end
end
