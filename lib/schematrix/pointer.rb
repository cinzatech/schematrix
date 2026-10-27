require "uri"

module Schematrix
  # Escaping of one JSON pointer token inside a URI fragment. Schema
  # keys are folded into locator fragments, where "/" separates
  # containment levels and "%" starts an escape: a key carrying
  # either would change the pointer's shape or leave the locator
  # string unparseable. Escaping makes every fragment a valid URI
  # whose tokens decode back to the original keys; unescaping reverses
  # it per token, percent layer first (a document author's %7E1 means
  # the pointer escape ~1), then the JSON pointer layer. A key's own
  # ~ and / land as ~0/~1 before the percent pass, so they decode
  # exactly once.
  module Pointer
    module_function

    # Percent-encodes one key for use as a fragment token. The JSON
    # pointer escapes land first (~0, ~1), so a key's own "~" and "/"
    # survive the reader's pointer pass; the URI parse then encodes
    # everything the fragment grammar cannot carry, and the brackets
    # the older grammar tolerated force explicitly.
    def escape(token)
      escaped = token.gsub("~", "~0").gsub("/", "~1")
      escaped = URI::RFC2396_PARSER.escape(escaped)
      escaped.gsub("~", "%7E").gsub("[", "%5B").gsub("]", "%5D")
    end

    # Decodes one fragment token back to its key: the URI percent
    # layer first (a document author's %7E1 means the pointer escape
    # ~1), then the JSON pointer layer. A key's own escapes landed as
    # ~0/~1 before encoding, so they decode exactly once.
    def unescape(token)
      URI::RFC2396_PARSER.unescape(token).gsub("~1", "/").gsub("~0", "~")
    end
  end
end
