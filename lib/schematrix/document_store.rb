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
  # Remote http(s) locators never touch the network: they resolve
  # through the configured schema directories (D16), which mirror the
  # URI as host/path below the directory, optionally carrying one of
  # the known file extensions.
  class DocumentStore
    # File extensions probed for a mapped remote URI, in order: the
    # exact mirrored path first, then common schema file extensions.
    REMOTE_EXTENSIONS = ["", ".json", ".yaml", ".yml"].freeze

    def initialize(schema_dirs: [])
      @schema_dirs = schema_dirs.map { |dir| File.expand_path(dir) }
      @documents = {}
      @anchors = {}
      @ignored = {}
    end

    # Returns the schema node the given URI points at, walking the
    # JSON pointer in the URI fragment.
    def node_at(uri)
      uri = canonicalize(uri)
      walk_pointer(document(uri), uri)
    end

    # Ignore bookkeeping: keywords with no codegen representation
    # are skipped; each one is logged once per document at debug
    # level. The key identifies a document (see document_key).
    def note_ignored(key, keyword, locator)
      seen = (@ignored[key] ||= Set.new)
      return unless seen.add?(keyword)

      Schematrix.logger&.debug(
        "Ignoring #{keyword} at #{locator}: no codegen representation",
      )
    end

    # Identity of the document a locator points into: the URI with
    # the fragment stripped. Every locator into the same document
    # shares one cache key this way, and documents on different
    # hosts (or schemes) never collide on a shared path.
    def document_key(uri)
      key = uri.dup
      key.fragment = nil
      key.to_s
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

    # D9 helper: the locator of the last schema carrying a
    # $dynamicAnchor with the given name, in document order. nil when
    # the document names no such anchor.
    def last_dynamic_anchor_locator(uri, name)
      segments = nil
      each_node(document(uri)) do |node, path|
        segments = path if node.is_a?(Hash) && node["$dynamicAnchor"] == name
      end
      return nil if segments.nil?

      locator = uri.dup
      locator.fragment = "/#{segments.map { |token| escape(token) }.join("/")}"
      locator
    end

    private

    def anchor_name?(uri)
      !uri.fragment.nil? && !uri.fragment.empty? &&
        !uri.fragment.start_with?("/")
    end

    # Depth-first scan of a parsed document in document order. Yields
    # every node with its path segments relative to the document root.
    def each_node(document)
      scan =
        lambda do |node, path|
          case node
          when Hash
            yield(node, path)
            node.each { |key, value| scan.call(value, path + [key]) }
          when Array
            node.each_with_index do |value, index|
              scan.call(value, path + [index.to_s])
            end
          end
        end
      scan.call(document, [])
    end

    # Scans a document once for $anchor keys: anchor name => JSON
    # pointer of the schema carrying it.
    def anchor_pointers(document, uri)
      @anchors[document_key(uri)] ||= begin
        pointers = {}
        each_node(document) do |node, segments|
          anchor = node["$anchor"]
          next unless anchor

          pointers[
            anchor
          ] = "/#{segments.map { |token| escape(token) }.join("/")}"
        end
        pointers
      end
    end

    def escape(token)
      token.to_s.gsub("~", "~0").gsub("/", "~1")
    end

    def document(uri)
      @documents[document_key(uri)] ||= read_document(uri)
    end

    # Reads and parses a document: local files directly, remote
    # locators through the schema directory mapping (D16).
    def read_document(uri)
      case uri.scheme
      when "file"
        YAML.safe_load_file(uri.path)
      when "http", "https"
        YAML.safe_load_file(map_remote(uri))
      else
        raise UnresolvableLocatorError, "Unsupported scheme in #{uri}"
      end
    end

    # D16 mapping: a remote locator resolves to the first existing
    # local file among the schema directories. Raises when the URI
    # cannot be mapped (query string) or nothing is found.
    def map_remote(uri)
      if uri.query
        raise UnresolvableLocatorError,
              "Cannot map #{uri} to a local file: query strings are " \
                "not part of the folder mapping"
      end
      if @schema_dirs.empty?
        raise UnresolvableLocatorError,
              "Remote locator #{uri} but no schema directory " \
                "configured (pass --schema-dir)"
      end

      candidates = remote_candidates(uri)
      candidate = candidates.find { |path| File.file?(path) }
      if candidate.nil?
        raise UnresolvableLocatorError,
              "No local file for #{uri}: none of " \
                "#{candidates.join(", ")} exists"
      end

      Schematrix.logger&.debug "Mapped #{uri} to #{candidate}"
      candidate
    end

    # Local paths a remote locator could map to, in lookup order:
    # schema directories in configuration order, mirrored host/path
    # names with each known extension. The port is kept in the first
    # path segment when the URI carries a non-default one.
    def remote_candidates(uri)
      host =
        if uri.port == uri.default_port
          uri.host
        else
          "#{uri.host}:#{uri.port}"
        end
      segments = [host]
      segments.concat(
        uri
          .path
          .delete_prefix("/")
          .split("/")
          .map { |segment| URI::DEFAULT_PARSER.unescape(segment) },
      )
      if segments.intersect?(%w[.. .])
        raise UnresolvableLocatorError,
              "Cannot map #{uri} to a local file: dot path segments " \
                "cannot leave the schema directory"
      end

      relative = File.join(*segments)

      @schema_dirs.flat_map do |dir|
        REMOTE_EXTENSIONS.map { |ext| "#{dir}/#{relative}#{ext}" }
      end
    end

    def walk_pointer(node, uri)
      tokens(uri.fragment).reduce(node) do |current, token|
        step(current, token)
      end
    rescue IndexError, TypeError, ArgumentError
      # ArgumentError: a non-numeric token against an array node
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
