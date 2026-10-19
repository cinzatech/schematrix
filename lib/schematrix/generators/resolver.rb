require "uri"

module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling
    module Resolver
      # Returns the qualified class name for a locator and, optionally,
      # one nested schema name (a property, an items branch, a variant
      # segment). Example: order.json#/properties/baz + "qux" resolves
      # the name to Order::Props::Baz::Qux.
      # Empty parts are removed. Container provenance is always encoded:
      # every 'properties' segment becomes a Props module level and
      # every '$defs' segment a Defs module level, so a property chain
      # and a definition chain can never fold onto the same class
      # name. "$" prefixes (core vocabulary keywords like "$id") and
      # mangling suffixes ("if_") are stripped so segments form valid
      # constant names, and characters constant names cannot carry
      # fold to separators ("web.hook" -> "WebHook").
      def class_name_from_path(uri, name = nil)
        file = File.basename(uri.path).split(".").first
        segments = [
          file,
          *uri.fragment.split("/"),
          *name.to_s.split("/"),
        ].compact.reject(&:empty?)

        meaningful =
          segments.filter_map do |segment|
            next "Props" if segment == "properties"
            next "Defs" if segment == "$defs"

            clean = segment.delete("$").gsub(/[^a-zA-Z\d\s_-]/, " ")
            clean = clean.strip.sub(/_+\z/, "")
            next if clean.empty?

            clean
          end

        pascal_case(meaningful.join("/"))
      end

      private

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
