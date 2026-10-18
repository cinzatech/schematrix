require "uri"
require "yaml"

module Schematrix
  # Raised when a locator points at a node that doesn't exist
  class UnresolvableLocatorError < StandardError
  end

  # Loads and caches schema documents, and resolves locator URIs to the
  # node they point at. Each file is read and parsed at most once.
  # Fragments that are plain names (no leading slash) resolve through
  # the document's $anchor index instead of the JSON pointer walk.
  class DocumentStore
    def initialize
      @documents = {}
      @anchors = {}
    end

    # Returns the schema node the given URI points at, walking the
    # JSON pointer in the URI fragment.
    def node_at(uri)
      uri = canonicalize(uri)
      walk_pointer(document(uri), uri)
    end

    # Rewrites plain-name fragments (no leading slash) to the JSON
    # pointer of the schema carrying that $anchor, so every consumer
    # of the locator (class names, edges, cycle guards) sees the
    # pointer form. Pointer fragments pass through unchanged.
    def canonicalize(uri)
      return uri unless anchor_name?(uri)

      pointer = anchor_pointers(document(uri), uri)[uri.fragment]
      if pointer.nil?
        raise UnresolvableLocatorError,
              "No $anchor named #{uri.fragment} in #{uri}"
      end

      rewritten = uri.dup
      rewritten.fragment = pointer
      rewritten
    end

    private

    def anchor_name?(uri)
      !uri.fragment.nil? && !uri.fragment.empty? &&
        !uri.fragment.start_with?("/")
    end

    # Scans a document once for $anchor keys: anchor name => JSON
    # pointer of the schema carrying it.
    def anchor_pointers(document, uri)
      @anchors[uri.path] ||= begin
        pointers = {}
        scan =
          lambda do |node, path|
            case node
            when Hash
              anchor = node["$anchor"]
              pointers[anchor] = path if anchor
              node.each do |key, value|
                scan.call(value, "#{path}/#{escape(key)}")
              end
            when Array
              node.each_with_index do |value, index|
                scan.call(value, "#{path}/#{index}")
              end
            end
          end
        scan.call(document, "")
        pointers
      end
    end

    def escape(token)
      token.to_s.gsub("~", "~0").gsub("/", "~1")
    end

    def document(uri)
      unless uri.scheme == "file"
        raise UnresolvableLocatorError, "Unsupported scheme in #{uri}"
      end

      @documents[uri.path] ||= YAML.safe_load_file(uri.path)
    end

    def walk_pointer(node, uri)
      tokens(uri.fragment).reduce(node) do |current, token|
        step(current, token)
      end
    rescue IndexError, TypeError
      raise UnresolvableLocatorError, "Nothing found at #{uri}"
    end

    def tokens(fragment)
      return [] if fragment.nil? || fragment.empty? || fragment == "/"

      fragment
        .split("/")
        .drop(1)
        .map { |token| token.gsub("~1", "/").gsub("~0", "~") }
    end

    def step(node, token)
      case node
      when Array
        node.fetch(Integer(token))
      else
        node.fetch(token)
      end
    end
  end
end
