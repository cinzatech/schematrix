require "uri"

module Schematrix
  module Generators
    # Common functions for Ruby class name and file handling
    module Resolver
      # Returns the qualified class name for a locator and, optionally,
      # one nested schema name (a property, an items branch, a variant
      # segment). Example: order.json#/properties/baz + "qux" resolves
      # the name to Order::Baz::Qux.
      # Empty parts are removed. 'properties' also removed, as is the
      # '$defs' container segment (but not a property named "$defs",
      # which only ever follows a 'properties' segment). "$" prefixes
      # (core vocabulary keywords like "$id") and mangling suffixes
      # ("if_") are stripped so segments form valid constant names.
      def class_name_from_path(uri, name = nil)
        file = File.basename(uri.path).split(".").first
        segments = [file, *uri.fragment.split("/"), name].compact.reject(
          &:empty?
        )

        meaningful =
          segments.each_with_index.filter_map do |segment, index|
            previous = index.zero? ? nil : segments[index - 1]
            defs_segment = index.positive? && segment == "$defs"
            container = defs_segment && previous != "properties"
            next if segment == "properties" || container

            segment.delete("$").sub(/_+\z/, "")
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
