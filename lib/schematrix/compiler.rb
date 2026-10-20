require "uri"

require_relative "document_store"
require_relative "visitor"

module Schematrix
  # Drives schema compilation with a worklist. Starting from the input
  # files, it visits each discovered locator exactly once, following
  # `$ref` edges on demand. Only schemas actually reachable from the
  # inputs are compiled.
  class Compiler
    # `store` is the Schematrix::DocumentStore every visitor shares.
    # `closed_shapes` treats an absent `additionalProperties` as false
    # (closed classes), instead of the spec's open default.
    def initialize(store: DocumentStore.new, closed_shapes: false)
      @store = store
      @closed_shapes = closed_shapes
      @queue = []
      @seen = Set.new
      @objects = {}
    end

    # Returns a hash of locator => Schema for every object schema
    # reachable from the given input files. Locators are URI strings
    # (`file:///path/schema.json#/properties/address`); the Schema
    # records are the internal representation the generators render.
    def compile(input_files)
      input_files.each { |file| discover(root_locator(file)) }

      visit(@queue.shift) until @queue.empty?

      @objects
    end

    private

    # Compiles one locator through a Visitor and merges its findings:
    # objects into the registry, edges into the worklist.
    def visit(uri)
      node = @store.node_at(uri)
      visitor =
        Visitor.new(uri, @store, closed_shapes: @closed_shapes).compile(node)

      @objects.merge!(visitor.objects)
      visitor.edges.each { |edge| discover(edge) }
    end

    # Queues a locator for visiting. The seen set drops repeats, so
    # each locator compiles exactly once even under diamond-shaped
    # reference graphs.
    def discover(uri)
      return unless @seen.add?(uri.to_s)

      @queue << uri
    end

    # The file:// locator of a document root. The expanded path is
    # percent-escaped so it stays a valid URI; readers unescape it
    # back.
    def root_locator(input_file)
      # Paths may carry characters a URI cannot (spaces), so the
      # expanded path is percent-escaped; readers unescape it back.
      path = URI::RFC2396_PARSER.escape(File.expand_path(input_file))
      URI("file://#{path}#/")
    end
  end
end
