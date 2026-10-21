require_relative "base"
require_relative "coercions"

module Schematrix
  module Generators
    module Templates
      # Constructor and from_h/to_h rendering shared by the
      # Ruby-emitting formats
      module RubyHelpers
        include Coercions

        def constructor_arguments
          return "" if @properties.nil? || @properties.empty?

          args =
            constructor_properties
              .map do |name, schema|
                unless schema.default.nil?
                  next "#{name}: #{schema.default.inspect}"
                end
                next "#{name}: nil" unless schema.required

                "#{name}:"
              end
              .join(", ")

          "(#{args})"
        end

        # Constructor kwargs in the order Ruby reports for the method:
        # required keywords first, then optional ones, each group in
        # document order. Method#parameters normalizes that way, and
        # sorbet-runtime validates the sig against it, so a required
        # property after an optional one must still emit first.
        def constructor_properties
          required, optional =
            @properties.partition do |_name, schema|
              schema.required && schema.default.nil?
            end
          (required + optional).to_h
        end

        def constructor_assignments
          return "" if @properties.nil?

          @properties.map { |name, _schema| "@#{name} = #{name}" }.join("\n")
        end

        # The original-name key map the class carries: known
        # keys in their document spelling. Absent when the schema
        # declares no properties.
        def original_keys_constant
          return "" if @property_keys.empty?

          pairs =
            @property_keys.map do |original, name|
              "  #{original.inspect} => #{name.inspect}"
            end
          "ORIGINAL_KEYS = {\n#{pairs.join(",\n")}\n}.freeze"
        end

        # from_h: builds an instance from a String-keyed hash
        # as parsed from a document. Known keys land in their slots
        # (original spelling, values coerced when they carry a class);
        # absent defaulted keys stay absent so constructor defaults
        # apply; unknown keys ride the catch-all with their original
        # names.
        def from_h_method
          <<~RUBY
            def self.from_h(hash)
            #{indented(from_h_body, 1)}
            end
          RUBY
        end

        def from_h_body
          kwargs = load_kwargs
          assignments = load_assignments
          construction = kwargs.empty? ? "new" : "new(#{kwargs.join(",\n")})"
          if assignments.empty? && @additional_properties.nil?
            return construction
          end

          lines = ["instance = #{construction}", *assignments]
          if @additional_properties
            lines << ""
            lines << "hash.each do |key, value|"
            unless @property_keys.empty?
              lines << "  next if ORIGINAL_KEYS.key?(key)"
            end
            lines << ""
            lines << "  instance[key] = value"
            lines << "end"
          end
          lines << "instance"
          lines.join("\n")
        end

        # Constructor kwargs of from_h: every property without a
        # constructor default. Absent keys pass nil, which is what
        # those kwargs default to anyway; required kwargs receive nil
        # rather than an ArgumentError, the loader stays
        # over-accepting.
        def load_kwargs
          defaulted_free_properties.map do |name|
            "#{name}: #{load_value(name)}"
          end
        end

        # Post-construction assignments of from_h: properties with a
        # constructor default, assigned only when the document carries
        # the key, so absence keeps the default.
        def load_assignments
          defaulted_properties.map do |name|
            "instance.#{name} = #{load_value(name)} " \
              "if hash.key?(\"#{original_key_of(name)}\")"
          end
        end

        # The from_h value expression of one property: the raw hash
        # lookup, or the lookup wrapped in its coercion when the
        # property carries a class-shaped term.
        def load_value(name)
          source = "hash[\"#{original_key_of(name)}\"]"
          return source unless coerced_property_names.include?(name)

          "coerce_#{name}(#{source})"
        end

        def defaulted_free_properties
          @property_keys.filter_map do |_original, name|
            name.to_s if @properties[name.to_s].default.nil?
          end
        end

        def defaulted_properties
          @property_keys.filter_map do |_original, name|
            name.to_s unless @properties[name.to_s].default.nil?
          end
        end

        def coerced_property_names
          property_coercions
            .filter_map { |name, plan| name unless plan.nil? }
            .to_set
        end

        # to_h: the inverse of from_h. Original key names,
        # nested instances dumped through their own to_h, absent
        # slots omitted, catch-all riders merged under their original
        # String keys.
        def to_h_method
          <<~RUBY
            def to_h
            #{indented(to_h_body, 1)}
            end
          RUBY
        end

        def to_h_body
          return "{}" if @property_keys.empty? && @additional_properties.nil?

          lines = ["result = {}"]
          property_coercions.each do |name, plan|
            value =
              (plan.nil? ? "@#{name}" : "self.class.coerce_#{name}(@#{name})")
            lines << "result[\"#{original_key_of(name)}\"] = #{value} " \
              "unless @#{name}.nil?"
          end
          if @additional_properties
            lines << "@_extra.each { |key, value| result[key] = value }"
          end
          lines << "result"
          lines.join("\n")
        end

        def original_key_of(name)
          @property_keys.to_h.key(name.to_sym)
        end
      end
    end
  end
end
