require "uri"

module Schematrix
  # Escaping of one JSON pointer token inside a URI fragment. Schema
  # keys are folded into locator fragments, where "/" separates
  # containment levels and "%" starts an escape: a key carrying
  # either would change the pointer's shape or leave the locator
  # string unparseable. Escaping makes every fragment a valid URI
  # whose tokens decode back to the original keys; unescaping is the
  # inverse, per token, tilde first (the JSON pointer escape, so a
  # key's literal "~1" survives) and percent second.
  module Pointer
    module_function

    # Percent-encodes one key for use as a fragment token. The URI
    # parser escapes "%" and the characters no URI parser accepts in
    # a fragment, but leaves "/", "~" and the brackets its older
    # grammar tolerated, so those are forced explicitly after it.
    def escape(token)
      escaped = URI::RFC2396_PARSER.escape(token)
      escaped
        .gsub("/", "%2F")
        .gsub("~", "%7E")
        .gsub("[", "%5B")
        .gsub("]", "%5D")
    end

    # Decodes one fragment token back to its key. "~1" and "~0" are
    # the JSON pointer spellings of "/" and "~"; percent-escapes
    # decode last, so a key's own percent signs never re-enter the
    # tilde pass.
    def unescape(token)
      unescaped = token.gsub("~1", "/").gsub("~0", "~")
      URI::RFC2396_PARSER.unescape(unescaped)
    end
  end
end
