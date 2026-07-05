require 'uri'
require 'yaml'

module Schematrix
  # Raised when a locator points at a node that doesn't exist
  class UnresolvableLocatorError < StandardError; end

  # Loads and caches schema documents, and resolves locator URIs to the
  # node they point at. Each file is read and parsed at most once.
  class DocumentStore
    def initialize
      @documents = {}
    end

    # Returns the schema node the given URI points at, walking the
    # JSON pointer in the URI fragment.
    def node_at(uri)
      walk_pointer(document(uri), uri)
    end

    private

    def document(uri)
      raise UnresolvableLocatorError, "Unsupported scheme in #{uri}" unless uri.scheme == 'file'

      @documents[uri.path] ||= YAML.safe_load(File.read(uri.path))
    end

    def walk_pointer(node, uri)
      tokens(uri.fragment).reduce(node) do |current, token|
        step(current, token)
      end
    rescue IndexError, TypeError
      raise UnresolvableLocatorError, "Nothing found at #{uri}"
    end

    def tokens(fragment)
      return [] if fragment.nil? || fragment.empty? || fragment == '/'

      fragment.split('/').drop(1).map do |token|
        token.gsub('~1', '/').gsub('~0', '~')
      end
    end

    def step(node, token)
      case node
      when Array then node.fetch(Integer(token))
      else node.fetch(token)
      end
    end
  end
end
