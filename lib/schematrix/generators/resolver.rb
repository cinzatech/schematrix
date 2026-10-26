require "uri"

require_relative "../pointer"

module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling: how a
    # schema locator becomes a class name, and how names nest.
    module Resolver
      # Returns the qualified class name for a locator and, optionally,
      # one nested schema name (a property, an items branch, a variant
      # segment). Example: order.json#/properties/baz + "qux" resolves
      # the name to Order::Props::Baz::Qux.
      # Empty parts are removed. Container provenance is always encoded:
      # every 'properties' segment becomes a Props module level and
      # every '$defs' segment a Defs module level, so a property chain
      # and a definition chain can never fold onto the same class
      # name. Fragment segments decode through Pointer before folding,
      # so a locator and the property name it was built from fold to
      # one name. "$" prefixes (core vocabulary keywords like "$id")
      # and mangling suffixes ("if_") are stripped so segments form
      # valid constant names, characters constant names cannot carry
      # fold to separators ("web.hook" -> "WebHook"), names with no
      # representable character fold to their UTF-8 hex ("@" ->
      # "N40"), and a part that would start with a digit takes an
      # "N" prefix ("2fa" -> "N2fa"), the constant-safe spelling.
      def class_name_from_path(uri, name = nil)
        file =
          File.basename(URI::RFC2396_PARSER.unescape(uri.path)).split(".").first
        segments = [
          file,
          *uri.fragment.split("/").map { |part| Pointer.unescape(part) },
          *name.to_s.split("/"),
        ].compact.reject(&:empty?)

        meaningful =
          segments.filter_map do |segment|
            next "Props" if segment == "properties"
            next "Defs" if segment == "$defs"

            clean = segment.delete("$").gsub(/[^a-zA-Z\d\s_-]/, " ")
            clean = clean.strip.sub(/_+\z/, "")
            clean = segment.unpack1("H*") if clean.empty?
            next if clean.empty?

            clean
          end

        pascal_case(meaningful.join("/"))
          .split("::")
          .map { |part| part.sub(/\A(\d)/, "N\\1") }
          .join("::")
      end

      private

      # Folds a /-separated segment chain into one PascalCase constant
      # name with :: separators.
      def pascal_case(string)
        string
          .to_s
          .gsub("/", "::")
          .gsub(/\s*::\s*([a-zA-Z\d])/) { "::#{Regexp.last_match(1).upcase}" }
          .gsub(/(?:^|[\s_-]+)([a-zA-Z\d])/) { Regexp.last_match(1).upcase }
      end

      # Returns a locator one level below the given one, naming the
      # nested schema (property, items, ...). Recursions through it keep
      # the property name in the path so class names resolve to the
      # locators the compiler registered, e.g. Schema::Entries::Items.
      def nested_locator(uri, name)
        child = uri.dup
        child.fragment = "#{uri.fragment}/#{name}"
        child
      end
    end
  end
end
