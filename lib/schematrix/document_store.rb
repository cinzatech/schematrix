require "uri"
require "yaml"

require_relative "pointer"

module Schematrix
  # Raised when a locator points at a node that does not exist: a bad
  # JSON pointer, an unknown `$anchor`, an unmapped remote URI, or an
  # unsupported URI scheme.
  class UnresolvableLocatorError < StandardError
  end

  # Raised when a loaded document cannot be a JSON Schema at all:
  # anything but an object or a boolean.
  class InvalidSchemaError < StandardError
  end

  # Raised when a document's `$schema` header names a dialect that
  # schematrix cannot read as 2020-12: neither the 2020-12 metaschema
  # nor a local metaschema built on the 2020-12 vocabularies. The
  # compiler refuses the document instead of guessing.
  class UnsupportedDialectError < StandardError
  end

  # Loads and caches schema documents, and resolves locator URIs to the
  # node they point at. Each file is read and parsed at most once.
  # Fragments that are plain names (no leading slash) resolve through
  # the document's `$anchor` index instead of the JSON pointer walk.
  # Remote `http(s)` locators never touch the network: they resolve
  # through the configured schema directories, which mirror the URI as
  # host/path below the directory, optionally carrying one of the
  # known file extensions.
  class DocumentStore
    # File extensions probed for a mapped remote URI, in order: the
    # exact mirrored path first, then common schema file extensions.
    REMOTE_EXTENSIONS = ["", ".json", ".yaml", ".yml"].freeze

    # Ruby classes a parsed document may have to be a schema at all.
    SCHEMA_CLASSES = [Hash, TrueClass, FalseClass].freeze

    # Dialects this tool targets: the 2020-12 core metaschema, http
    # and https spellings, with or without a trailing empty fragment.
    # A document without a header is read as 2020-12. A document
    # naming any other dialect goes through the vocabulary check (see
    # dialect_rejection).
    SUPPORTED_DIALECTS = %w[
      https://json-schema.org/draft/2020-12/schema
      http://json-schema.org/draft/2020-12/schema
    ].freeze

    # Vocabularies a custom dialect may require: the seven of the
    # 2020-12 metaschema. format-assertion is absent, because the
    # compiler never enforces `format`.
    SUPPORTED_VOCABULARIES = %w[
      https://json-schema.org/draft/2020-12/vocab/core
      https://json-schema.org/draft/2020-12/vocab/applicator
      https://json-schema.org/draft/2020-12/vocab/unevaluated
      https://json-schema.org/draft/2020-12/vocab/validation
      https://json-schema.org/draft/2020-12/vocab/meta-data
      https://json-schema.org/draft/2020-12/vocab/format-annotation
      https://json-schema.org/draft/2020-12/vocab/content
    ].freeze

    UNMAPPABLE_DIALECT =
      "the metaschema must be an http(s) URI without a fragment, " \
        "mapped to a local file in the schema directories"

    # `schema_dirs` lists the directories remote URIs resolve through,
    # in search order. An empty list means remote references fail
    # loudly instead of resolving.
    def initialize(schema_dirs: [])
      @schema_dirs = schema_dirs.map { |dir| File.expand_path(dir) }
      @documents = {}
      @anchors = {}
      @dynamic_anchors = {}
      @ignored = {}
      @dialect_rejections = {}
      @roots = {}
      @mapped_files = {}
    end

    # Records the root locator of an input file. A remote locator that
    # maps to the same file on disk gets this locator as its
    # compilation key (see compilation_key), so the schema compiles
    # once whatever route reaches it.
    def register_root(locator)
      @roots[file_identity(unescape_path(locator.path))] = locator
    end

    # The locator that identifies a schema in the compiled output:
    # for a remote locator whose file is an input file, that input's
    # root locator with the remote fragment; else the locator itself.
    # The key never replaces the locator as a base: relative
    # references in a remote document resolve against its remote URI,
    # which maps through the schema directories.
    def compilation_key(uri)
      return uri if @roots.empty?
      return uri unless %w[http https].include?(uri.scheme)

      root = @roots[file_identity(mapped_file(uri))]
      return uri if root.nil?

      key = root.dup
      key.fragment = uri.fragment
      key
    end

    # Returns the schema node the given URI points at: the document is
    # loaded (and validated) on first access, the `$anchor` form of
    # the fragment is rewritten to its pointer, and the JSON pointer
    # is walked. Raises UnresolvableLocatorError when the pointer
    # names nothing.
    def node_at(uri)
      uri = canonicalize(uri)
      walk_pointer(document(uri), uri)
    end

    # Registry hook for keywords with no codegen representation: each
    # one is logged once per document, at debug level. The key
    # identifies a document (see document_key).
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
    # pointer of the schema carrying that `$anchor`, so every consumer
    # of the locator (class names, edges, cycle guards) sees the
    # pointer form. Pointer fragments pass through unchanged. Raises
    # UnresolvableLocatorError when the document names no such anchor.
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

    # The locator of the last schema carrying a `$dynamicAnchor` with
    # the given name, in document order. nil when the document names
    # no such anchor. This is the fallback resolution for
    # `$dynamicRef` (the static approximation lives in Visitor).
    def last_dynamic_anchor_locator(uri, name)
      anchors =
        @dynamic_anchors[document_key(uri)] ||= begin
          index = {}
          each_node(document(uri)) do |node, path|
            anchor = node["$dynamicAnchor"]
            index[anchor] = path if anchor
          end
          index
        end
      segments = anchors[name]
      return nil if segments.nil?

      locator = uri.dup
      locator.fragment = "/#{segments.map { |token| escape(token) }.join("/")}"
      locator
    end

    private

    # The path that identifies a file on disk: symbolic links are
    # resolved when the file exists.
    def file_identity(path)
      File.realpath(path)
    rescue SystemCallError
      File.expand_path(path)
    end

    # Whether the fragment names an $anchor: a plain name with no
    # leading slash and not empty.
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

    # Escapes one JSON pointer token for a fragment the store builds:
    # the shared Pointer spelling, so the tokens a locator carries
    # round-trip through Pointer.unescape.
    def escape(token)
      Pointer.escape(token)
    end

    # Undoes the percent-escaping Compiler#root_locator applied to a
    # file path.
    def unescape_path(path)
      URI::RFC2396_PARSER.unescape(path)
    end

    # The parsed document a locator belongs to, read and parsed on
    # first access and cached per document key.
    def document(uri)
      key = document_key(uri)
      @documents.fetch(key) { @documents[key] = read_document(uri) }
    end

    # Reads and parses a document: local files directly, remote
    # locators through the schema directory mapping. Every document is
    # validated on first load (see validate_document).
    def read_document(uri)
      document =
        case uri.scheme
        when "file"
          YAML.safe_load_file(unescape_path(uri.path))
        when "http", "https"
          YAML.safe_load_file(mapped_file(uri))
        else
          raise UnresolvableLocatorError, "Unsupported scheme in #{uri}"
        end

      validate_document(document, uri)
      document
    end

    # Load-time validation. A document that cannot be a schema
    # (anything but an object or a boolean) raises InvalidSchemaError
    # instead of crashing later on keyword reads, and a `$schema`
    # header naming a dialect that cannot be read as 2020-12 raises
    # UnsupportedDialectError instead of being read with the wrong
    # semantics. Documents without a header are read as 2020-12.
    def validate_document(document, uri)
      unless SCHEMA_CLASSES.any? { |type| document.is_a?(type) }
        raise InvalidSchemaError,
              "#{uri} is not a schema document: expected an object " \
                "or a boolean, got #{document.class}"
      end

      dialect = document["$schema"] if document.is_a?(Hash)
      return if dialect.nil?

      normalized = dialect.to_s.chomp("#")
      return if SUPPORTED_DIALECTS.include?(normalized)

      reason =
        @dialect_rejections.fetch(normalized) do
          @dialect_rejections[normalized] = dialect_rejection(normalized)
        end
      return if reason.nil?

      raise UnsupportedDialectError,
            "#{uri} declares dialect #{dialect}, schematrix supports " \
              "#{SUPPORTED_DIALECTS.first} and dialects built on its " \
              "vocabularies: #{reason}"
    end

    # Why a dialect other than the 2020-12 metaschema cannot be read
    # as 2020-12, or nil when it can. The metaschema is read from the
    # schema directories without validation: its own `$schema` has no
    # effect, because `$vocabulary` is not inherited between
    # metaschemas, and a metaschema that names itself must not loop.
    # A vocabulary marked false is optional, so its keywords are
    # unknown keywords.
    def dialect_rejection(dialect)
      meta_uri = URI(dialect)
      unless %w[http https].include?(meta_uri.scheme) && meta_uri.fragment.nil?
        return UNMAPPABLE_DIALECT
      end

      meta = YAML.safe_load_file(map_remote(meta_uri))
      vocabulary = meta["$vocabulary"] if meta.is_a?(Hash)
      unless vocabulary.is_a?(Hash)
        return "the metaschema has no $vocabulary at its root"
      end

      required = vocabulary.select { |_, flag| flag == true }.keys
      unsupported = required - SUPPORTED_VOCABULARIES
      return nil if unsupported.empty?

      "the metaschema requires unsupported vocabularies: " \
        "#{unsupported.join(", ")}"
    rescue URI::InvalidURIError
      "the dialect is not a URI"
    rescue UnresolvableLocatorError => e
      "no local file for the metaschema (#{e.message})"
    rescue Psych::Exception => e
      "the metaschema file does not parse (#{e.message})"
    end

    # The local file of a remote locator, mapped once per document.
    def mapped_file(uri)
      key = document_key(uri)
      @mapped_files.fetch(key) { @mapped_files[key] = map_remote(uri) }
    end

    # Maps a remote locator to the first existing local file among the
    # schema directories. Raises when the URI cannot be mapped (query
    # string) or nothing is found (every candidate is listed).
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
          .map { |segment| URI::RFC2396_PARSER.unescape(segment) },
      )
      if segments.intersect?(%w[.. .])
        raise UnresolvableLocatorError,
              "Cannot map #{uri} to a local file: dot path segments " \
                "cannot leave the schema directory"
      end
      if segments.any? { |segment| segment.include?("/") }
        raise UnresolvableLocatorError,
              "Cannot map #{uri} to a local file: an escaped slash " \
                "cannot add path segments"
      end

      relative = File.join(*segments)

      @schema_dirs.flat_map do |dir|
        REMOTE_EXTENSIONS.map { |ext| "#{dir}/#{relative}#{ext}" }
      end
    end

    # Walks the fragment's pointer from the document root, one step
    # per token. Raises UnresolvableLocatorError when any step fails.
    def walk_pointer(node, uri)
      tokens(uri.fragment).reduce(node) do |current, token|
        step(current, token)
      end
    rescue IndexError, TypeError, ArgumentError
      # ArgumentError: a non-numeric token against an array node
      raise UnresolvableLocatorError, "Nothing found at #{uri}"
    end

    # Splits a fragment into JSON pointer tokens: the leading empty
    # segment is dropped and each token decodes through Pointer
    # (tilde escapes first, then percent-escapes, so a $ref to a key
    # written "first%20name" or "a~1b" finds it).
    def tokens(fragment)
      return [] if fragment.nil? || fragment.empty? || fragment == "/"

      fragment.split("/", -1).drop(1).map { |token| Pointer.unescape(token) }
    end

    # One pointer step: array nodes index numerically, hash nodes
    # fetch by key.
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
