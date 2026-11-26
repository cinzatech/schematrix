require "uri"

require_relative "../pointer"

module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling: how a
    # schema locator becomes a class name, and how names nest.
    module Resolver
      # Returns the class name for a locator and, optionally, one
      # nested schema name (a property, an items branch, a variant
      # segment), without the module. Example: order.json#/properties/baz
      # + "qux" resolves to Order::Props::Baz::Qux. The first part is
      # the class name of the document (see #document_class_name), and
      # the parts after it fold from the path inside the document.
      # Empty parts are removed. Container provenance is always encoded:
      # every 'properties' segment becomes a Props module level and
      # every '$defs' segment a Defs module level, so a property chain
      # and a definition chain can never fold onto the same class
      # name. Fragment segments decode through Pointer before folding.
      # A segment that names a property folds exactly like the mangled
      # accessor the parent derives its references from, so a locator
      # and the property name it was built from fold to one name;
      # definition keys have no mangled counterpart and keep their own
      # fold. "$" prefixes (core vocabulary keywords like "$id") and
      # mangling suffixes ("if_") are stripped so segments form valid
      # constant names, characters constant names cannot carry fold to
      # separators ("web.hook" -> "WebHook"), names with no
      # representable character fold to their UTF-8 hex ("@" -> "N40"),
      # and a part that would start with a digit takes an "N" prefix
      # ("2fa" -> "N2fa"), the constant-safe spelling.
      def class_name_from_path(uri, name = nil)
        segments = [
          *uri.fragment.split("/").map { |part| Pointer.unescape(part) },
          *name.to_s.split("/"),
        ].reject(&:empty?)

        parts = [document_class_name(uri), fold_segments(segments)]
        parts.reject(&:empty?).join("::")
      end

      # The class name of the document that holds the locator: its file
      # name up to the first period, folded. `order.schema.json` gives
      # `Order`. Generators and templates take it from their naming
      # object instead.
      def document_class_name(uri)
        file = File.basename(URI::RFC2396_PARSER.unescape(uri.path))
        fold_segments([file.split(".").first.to_s].reject(&:empty?))
      end

      private

      def fold_segments(segments)
        follows_properties = false
        meaningful =
          segments.filter_map do |segment|
            property_segment = follows_properties
            follows_properties = false

            unless property_segment
              case segment
              when "properties"
                follows_properties = true
                next "Props"
              when "$defs"
                next "Defs"
              end
            end

            clean =
              if property_segment
                # A property name folds exactly like the mangled
                # accessor the parent derives its references from. The
                # mangler turns "$" into a separator, so only a leading
                # "$" (a keyword like "$id") disappears here; an
                # interior one folds to the same separator.
                underscore(segment.sub(/\A\$+/, ""))
              else
                segment.delete("$")
              end
            clean = clean.gsub(/[^a-zA-Z\d\s_-]/, " ")
            clean = clean.strip.sub(/[\s_-]+\z/, "")
            clean = segment.unpack1("H*") if clean.empty?
            next if clean.empty?

            clean
          end

        pascal_case(meaningful.join("/"))
          .split("::")
          .map { |part| part.sub(/\A(\d)/, "N\\1") }
          .join("::")
      end

      # Snake-cases a name the way the property mangling spells it:
      # case boundaries become separators and everything lowercases,
      # so a segment read from a locator folds exactly like the
      # mangled property name the parent derives its references from.
      def underscore(string)
        string
          .to_s
          .gsub("::", "/")
          .gsub(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr("-", "_")
          .downcase
      end

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
