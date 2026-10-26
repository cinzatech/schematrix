require "tty-logger"

require_relative "schematrix/version"
require_relative "schematrix/meta"
require_relative "schematrix/scalar_types"
require_relative "schematrix/compiler"

# Compiles JSON Schema documents and generates Ruby source and type
# signatures from them. The CLI (Schematrix::CLI) and the library entry
# point (Schematrix.generate) share this pipeline.
module Schematrix
  class << self
    # The pipeline logs through this object when one is set. `nil` by
    # default, so library runs are silent. The CLI assigns a
    # TTY::Logger; anything answering `debug`, `info`, `warn` and
    # `fatal` works.
    attr_accessor :logger
  end

  # Raised before any file is written, when two outputs would land on
  # the same path: two input files with the same basename, two
  # generators sharing a file extension in one output directory, or
  # names whose folding collides.
  class OutputCollisionError < StandardError
  end

  # Raised while rendering a class whose coerced property names fold
  # onto the shared coercion helpers: the delegating property methods
  # would override the helpers they call.
  class CoercionHelperCollisionError < StandardError
  end

  # Raised while rendering a class whose schema unions branches that
  # would convert the same JSON type through different coercers: a
  # loaded value carries no mark of the branch it came from, so no
  # converter is correct for every instance the union accepts.
  class CoercionConflictError < StandardError
  end

  # Compiles every schema reachable from `input_files` and writes one
  # file per compiled object schema per generator.
  #
  # - `generators`: generator instances, one per output format. Each
  #   receives a `write(locator, node)` call per compiled class.
  # - `input_files`: paths to JSON or YAML schema documents. Each is a
  #   compilation root; `$ref` edges reachable from it are followed.
  # - `closed_shapes`: when true, an absent `additionalProperties`
  #   behaves as `false` (closed classes, no catch-all). The spec
  #   default is the open catch-all.
  # - `schema_dirs`: directories that remote `http(s)` schema URIs
  #   resolve through, in search order. Nothing is ever fetched over
  #   the network.
  #
  # Returns the compiled records as a hash keyed by schema locator
  # (a URI string such as
  # `file:///path/person.schema.json#/properties/address`), with
  # Schematrix::Schema values.
  #
  # Raises Schematrix::InvalidSchemaError when a document cannot be a
  # schema, Schematrix::UnsupportedDialectError when a `$schema` header
  # names a dialect other than draft 2020-12,
  # Schematrix::UnresolvableLocatorError when a reference cannot be
  # resolved, Schematrix::OutputCollisionError when two outputs would
  # share one file, and Schematrix::CoercionHelperCollisionError when
  # a property name would override a generated coercion helper.
  # Output collisions are detected before the first write, so such
  # failures leave no partial output.
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

  # Checks that every generator writing every compiled locator lands on
  # a distinct file, and raises Schematrix::OutputCollisionError when
  # two outputs share a path. Container provenance is part of every
  # class name, so distinct locators almost always map to distinct
  # files; this check catches what name folding cannot express (two
  # input files with the same basename, property names that normalize
  # to one identifier, two same-extension generators in one directory)
  # before any file is written.
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
