require 'set'
require 'uri'

require_relative 'document_store'
require_relative 'visitor'

module Schematrix
  # Drives schema compilation with a worklist. Starting from the input
  # files, it visits each discovered locator exactly once, following $ref
  # edges on demand. Only schemas actually reachable from the inputs are
  # compiled.
  class Compiler
    def initialize(store: DocumentStore.new)
      @store = store
      @queue = []
      @seen = Set.new
      @objects = {}
    end

    # Returns a hash of locator => Schema for every object schema
    # reachable from the given input files.
    def compile(input_files)
      input_files.each { |file| discover(root_locator(file)) }

      visit(@queue.shift) until @queue.empty?

      @objects
    end

    private

    def visit(uri)
      node = @store.node_at(uri)
      visitor = Visitor.new(uri, @store).compile(node)

      @objects.merge!(visitor.objects)
      visitor.edges.each { |edge| discover(edge) }
    end

    def discover(uri)
      return unless @seen.add?(uri.to_s)

      @queue << uri
    end

    def root_locator(input_file)
      URI("file://#{File.expand_path(input_file)}#/")
    end
  end
end
