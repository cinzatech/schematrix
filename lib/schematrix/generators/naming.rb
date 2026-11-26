require "uri"

require_relative "resolver"

module Schematrix
  # The names that a run gives to each document when no generator
  # receives a `names:` object: the `-m` module, and the class name
  # from the file name (`order.schema.json` gives `Order`). A project
  # can inherit from it and change one method or both.
  class DefaultNames
    include Generators::Resolver

    private(*Generators::Resolver.public_instance_methods)

    def initialize(module_name)
      @module_name = module_name
    end

    def module_name(_locator) = @module_name

    def class_name(locator) = document_class_name(URI(locator))
  end

  module Generators
    # Asks the names object of a run for the module and the class name
    # of each document, once for each document. The object receives
    # the root locator of the document (`file:///path/order.json#/`).
    # A value that is not a constant path stops the run with
    # ArgumentError. A document whose module is the `-m` module (the
    # root module) writes to the output directory. Another module adds
    # its own directory.
    class Naming
      include Resolver

      def self.constant_path?(name)
        return false unless name.is_a?(String)

        path = name.delete_prefix("::")
        return false if path.empty?

        validator = Module.new
        path
          .split("::", -1)
          .each { |part| validator.const_defined?(part, false) }
        true
      rescue NameError
        false
      end

      def initialize(names, root_module)
        @names = names
        @root_module = root_module
        @modules = {}
        @classes = {}
      end

      attr_reader :names

      def module_name(uri)
        locator = document_locator(uri)
        @modules[locator] ||= begin
          value = @names.module_name(locator)
          unless self.class.constant_path?(value)
            raise ArgumentError,
                  "names.module_name(#{locator}) returned #{value.inspect}, " \
                    "which is not a constant path"
          end
          value.delete_prefix("::")
        end
      end

      def class_name(uri)
        locator = document_locator(uri)
        @classes[locator] ||= begin
          value = @names.class_name(locator)
          unless self.class.constant_path?(value) && !value.include?("::")
            raise ArgumentError,
                  "names.class_name(#{locator}) returned #{value.inspect}, " \
                    "which is not a constant name"
          end
          value
        end
      end

      # The directory below the output directory that holds the files
      # of a module, as path parts.
      def directory_for(module_name)
        module_name == @root_module ? [] : underscore(module_name).split("/")
      end

      def directory(uri) = directory_for(module_name(uri))

      private

      def document_locator(uri)
        root = URI(uri.to_s)
        root.fragment = "/"
        root.to_s
      end
    end
  end
end
