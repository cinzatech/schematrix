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
          groups = []
          unless @properties.nil? || @properties.empty?
            groups << constructor_properties.map do |name, schema|
              defaulted = !schema.default.nil? && !maybe_partial_slot?(name)
              if defaulted
                if maybe_slot?(name)
                  next "#{name}: #{maybe_constructor_default(schema)}"
                end

                next "#{name}: #{schema.default.inspect}"
              end
              next "#{name}: #{maybe_type_name}.empty" if maybe_slot?(name)
              next "#{name}: nil" unless schema.constructor_required?

              "#{name}:"
            end
          end
          groups << "_extra: {}" if immutable? && !@additional_properties.nil?
          return "" if groups.empty?

          "(#{groups.join(", ")})"
        end

        # The constructor default of a maybe slot: the schema default
        # wraps as Present, so an absent key still loads the default
        # and dumps it.
        def maybe_constructor_default(schema)
          "#{maybe_type_name}.from(#{schema.default.inspect})"
        end

        # Whether one slot wraps in the Maybe type.
        def maybe_slot?(name)
          maybe_wrapped?(@properties.fetch(name.to_s))
        end

        # Constructor kwargs in the order Ruby reports for the method:
        # required keywords first, then optional ones, each group in
        # document order. Method#parameters normalizes that way, and
        # sorbet-runtime validates the sig against it, so a required
        # property after an optional one must still emit first.
        def constructor_properties
          required, optional =
            @properties.partition do |_name, schema|
              schema.constructor_required?
            end
          (required + optional).to_h
        end

        def constructor_assignments
          lines =
            if @properties.nil?
              []
            else
              @properties.map { |name, _schema| "@#{name} = #{name}" }
            end
          return lines.join("\n") unless immutable?

          unless @additional_properties.nil?
            lines << immutable_catch_all_assignment
          end
          lines << "freeze"
          lines.join("\n")
        end

        # The catch-all slot assignment of an immutable constructor:
        # the keyword's value, frozen so the instance stays deep
        # enough to share.
        def immutable_catch_all_assignment
          "@_extra = _extra.freeze"
        end

        # The value-object methods of an immutable class: the
        # copier and the equality trio. The protected catch-all
        # reader renders last in the class body, where the
        # visibility marker cannot leak onto later methods.
        def immutable_surface
          [with_method, equality_method, hash_method].join("\n")
        end

        # The copier: one optional keyword per property and one for
        # the catch-all as a whole, each defaulting to the value the
        # receiver holds.
        def with_method
          <<~RUBY
            def with(#{with_parameters})
              #{with_body}
            end
          RUBY
        end

        def with_parameters
          parameters = property_names.map { |name| "#{name}: @#{name}" }
          parameters << "_extra: @_extra" unless @additional_properties.nil?
          parameters.join(", ")
        end

        def with_body
          arguments = property_names.map { |name| "#{name}: #{name}" }
          arguments << "_extra: _extra" unless @additional_properties.nil?
          return "self.class.new" if arguments.empty?

          "self.class.new(#{arguments.join(", ")})"
        end

        # Value equality: the class, every property, and the
        # catch-all. The protected _extra reader answers for the
        # other side, which the is_a? guard narrows to instances.
        def equality_method
          terms = ["other.is_a?(self.class)"]
          terms.concat(
            property_names.map { |name| "other.#{name} == @#{name}" },
          )
          terms << "other._extra == @_extra" unless @additional_properties.nil?
          <<~RUBY
            def ==(other)
              #{terms.join(" && ")}
            end

            alias eql? ==
          RUBY
        end

        # The hash pair of the equality trio: the class keeps
        # subclasses with equal properties from colliding in Hashes.
        def hash_method
          values = property_names.map { |name| "@#{name}" }
          values << "@_extra" unless @additional_properties.nil?
          <<~RUBY
            def hash
              [self.class, #{values.join(", ")}].hash
            end
          RUBY
        end

        # The catch-all reader equality compares through: protected,
        # so only instances reach it, and underscored like the
        # keyword to stay clear of property readers.
        def protected_extra_reader
          <<~RUBY
            protected

            attr_reader :_extra
          RUBY
        end

        def property_names
          return [] if @properties.nil?

          @properties.keys
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
          return immutable_from_h_body if immutable?

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
            rider = extra_conversion? ? "coerce_extra(value)" : "value"
            lines << "  instance[key] = #{rider}"
            lines << "end"
          end
          lines << "instance"
          lines.join("\n")
        end

        # The immutable from_h: one construction call, every slot
        # through the constructor keyword it owns. Maybe slots build
        # Absent when the document lacks the key and Present(value)
        # when it carries it, null included; defaulted properties
        # assign only when the document carries their key, so absence
        # keeps the Present(default) the constructor supplied; and
        # the unknown keys gather into the _extra: keyword.
        def immutable_from_h_body
          lines = ["kwargs = {}"]
          defaulted_free_properties.each do |name|
            lines << "kwargs[:#{name}] = #{load_value(name)}"
          end
          defaulted_properties.each do |name|
            lines << load_assignment(name, kwargs: true)
          end
          if @additional_properties
            lines << "kwargs[:_extra] = " \
              "hash.each_with_object({}) do |(key, value), extras|"
            unless @property_keys.empty?
              lines << "  next if ORIGINAL_KEYS.key?(key)"
            end
            rider = extra_conversion? ? "coerce_extra(value)" : "value"
            lines << "  extras[key] = #{rider}"
            lines << "end"
          end
          return "new" if lines.size == 1

          lines << "new(**kwargs)"
          lines.join("\n")
        end

        # Whether the open class's extra riders convert through the
        # catch-all schema's coercing format.
        def extra_conversion? = !catch_all_spec.nil?

        # Constructor kwargs of from_h: every property without a
        # constructor default. Absent keys pass nil, which is what
        # those kwargs default to anyway; required kwargs receive nil
        # rather than an ArgumentError, the loader stays
        # over-accepting. Maybe slots read the key instead: Absent
        # when it is missing, Present(value) when it is there.
        def load_kwargs
          defaulted_free_properties.map do |name|
            if maybe_slot?(name)
              "#{name}: #{maybe_load_expression(name)}"
            else
              "#{name}: #{load_value(name)}"
            end
          end
        end

        # Post-construction assignments of from_h: properties with a
        # constructor default, assigned only when the document
        # carries the key, so absence keeps the default.
        def load_assignments
          defaulted_properties.map { |name| load_assignment(name) }
        end

        # The assignment of one defaulted property, guarded on the
        # document key. A maybe slot wraps the loaded value as
        # Present; the constructor default, Present(default) itself,
        # survives an absent key untouched. The immutable loader
        # writes into its kwargs hash, the mutable one onto the
        # instance.
        def load_assignment(name, kwargs: false)
          value =
            if maybe_slot?(name)
              maybe_loaded("#{maybe_reference}.from(#{load_value(name)})", name)
            else
              load_value(name)
            end
          place = kwargs ? "kwargs[:#{name}]" : "instance.#{name}"
          "#{place} = #{value} " \
            "if hash.key?(#{original_key_of(name).inspect})"
        end

        # The from_h expression of one maybe slot: Absent when the
        # document lacks the key, Present of the loaded (and, where
        # the slot coerces, converted) value when it is there.
        def maybe_load_expression(name)
          inner =
            "hash.key?(#{original_key_of(name).inspect}) ? " \
              "#{maybe_reference}.from(#{load_value(name)}) : " \
              "#{maybe_reference}.empty"
          maybe_loaded(inner, name)
        end

        # The escape hatch a notation applies to a loaded maybe slot.
        # from_h reads T.untyped document values, and a generic
        # constructor applied to an untyped argument widens to
        # T.anything, which no covariant Maybe accepts; the Sorbet
        # formats erase the slot's load expression back to untyped.

        # The from_h value expression of one property: the raw hash
        # lookup, or the lookup wrapped in its coercion when the
        # property carries a class-shaped term.
        def load_value(name)
          source = "hash[#{original_key_of(name).inspect}]"
          return source unless coerced_property_names.include?(name)

          "coerce_#{name}(#{source})"
        end

        def defaulted_free_properties
          @property_keys.filter_map do |_original, name|
            next name.to_s if maybe_partial_slot?(name)

            schema = @properties[name.to_s]
            name.to_s if schema.default.nil?
          end
        end

        def defaulted_properties
          @property_keys.filter_map do |_original, name|
            next if maybe_partial_slot?(name)

            schema = @properties[name.to_s]
            name.to_s unless schema.default.nil?
          end
        end

        # Whether one slot is a partial-class slot carrying a schema
        # default. A partial records which keys the document carried,
        # so a default never materializes from nothing: the slot
        # starts Absent and loads Present(default) only when the key
        # is there, unlike a data class, where absence loads the
        # default.
        def maybe_partial_slot?(name)
          @all_slots_maybe && maybe_slot?(name) &&
            !@properties.fetch(name.to_s).default.nil?
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
            if maybe_slot?(name)
              lines << maybe_dump_line(name, plan)
              next
            end
            value =
              (plan.nil? ? "@#{name}" : "self.class.coerce_#{name}(@#{name})")
            lines << "result[#{original_key_of(name).inspect}] = #{value} " \
              "unless @#{name}.nil?"
          end
          lines << extra_dump_line if @additional_properties
          lines << "result"
          lines.join("\n")
        end

        # The dump of one maybe slot: Absent writes nothing, Present
        # writes its value, null included; a coerced slot converts
        # the inner value. The generated Sorbet output dispatches
        # through the sealed case, where a missed case is a type
        # error; every other combination answers through the
        # interface's when_present.
        def maybe_dump_line(name, plan)
          key = original_key_of(name).inspect
          unwrapped = "@#{name}.value"
          converted =
            plan.nil? ? unwrapped : "self.class.coerce_#{name}(#{unwrapped})"
          if exhaustive_maybe_dump?
            <<~RUBY.rstrip
              case @#{name}
              when #{maybe_reference}::Present then result[#{key}] = #{converted}
              when #{maybe_reference}::Absent then nil
              else T.absurd(@#{name})
              end
            RUBY
          else
            inner = plan.nil? ? "value" : "self.class.coerce_#{name}(value)"
            "@#{name}.when_present { |value| result[#{key}] = #{inner} }"
          end
        end

        # The catch-all dump line: rider values convert through the
        # catch-all spec when it carries a coercing format.
        def extra_dump_line
          if extra_conversion?
            "@_extra.each { |key, value| result[key] = " \
              "self.class.coerce_extra(value) }"
          else
            "@_extra.each { |key, value| result[key] = value }"
          end
        end

        def original_key_of(name)
          @property_keys.to_h.key(name.to_sym)
        end
      end
    end
  end
end
