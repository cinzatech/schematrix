require_relative "test_helper"
require "tmpdir"

class TestEnumCoercions < Minitest::Test
  def test_direct_enum_coercion
    with_generated(
      { "enum" => ["active", "inactive", nil] },
    ) do |root, source, _namespace|
      refute_includes source, "require_relative"
      member = root.from_h("value" => "active").value
      assert_equal "active", member.serialize
      assert_same member, root.from_h("value" => "active").value
      assert_equal(
        { "value" => "active" },
        root.from_h("value" => "active").to_h,
      )
      assert_nil root.from_h("value" => nil).value
      assert_raises(KeyError) { root.from_h("value" => "missing") }
    end
  end

  def test_arrays_maps_tuples_and_catchall
    reference = { "$ref" => "#/$defs/status" }
    shapes = [
      [{ "type" => "array", "items" => reference }, [1, 2]],
      [
        {
          "type" => "array",
          "prefixItems" => [reference],
          "items" => reference,
        },
        [1, 2],
      ],
      [
        { "type" => "object", "additionalProperties" => reference },
        { "a" => 1, "b" => 2 },
      ],
    ]
    shapes.each do |shape, raw|
      with_generated(
        shape,
        members: [1, 2],
        catchall: reference,
      ) do |root, _source, _namespace|
        input = { "value" => raw, "extra" => 2 }
        instance = root.from_h(input)
        assert_equal 2, instance["extra"].serialize
        entries =
          instance.value.is_a?(Hash) ? instance.value.values : instance.value
        assert_equal [1, 2], entries.map(&:serialize)
        assert_equal input, instance.to_h
        assert_equal input, root.from_h(instance.to_h).to_h
        assert_raises(KeyError) { root.from_h("extra" => 99) }
      end
    end
  end

  def test_marked_refs_in_union_mode_and_format_composition
    reference = { "$ref" => "#/$defs/status" }
    with_generated(reference, mode: :unions) do |root, source, _namespace|
      refute_includes source, "coerce_value"
      refute_includes source, "[:class"
      assert_equal "active", root.from_h("value" => "active").value
    end
    %i[classes unions].each do |mode|
      with_generated(
        reference.merge("format" => "date"),
        mode:,
      ) do |root, source, _namespace|
        assert_includes source, "Schematrix::Coercers::Date.coerce(value)"
        date = root.from_h("value" => "2026-01-02").value
        assert_equal Date.new(2026, 1, 2), date
        assert_equal(
          { "value" => "2026-01-02" },
          root.from_h("value" => "2026-01-02").to_h,
        )
      end
    end
  end

  def test_enum_alternatives_dump_and_reload
    [%w[active shared], [1, 2]].each do |members|
      second = [members.last, members.first.is_a?(String) ? "other" : 3]
      alternatives = {
        "anyOf" => [
          { "$ref" => "#/$defs/status" },
          { "oneOf" => [{ "$ref" => "#/$defs/second" }, { "type" => "null" }] },
        ],
      }
      with_generated(
        alternatives,
        members:,
        second:,
      ) do |root, source, namespace|
        assert_includes source, "[:try, [:coerce,"
        assert_includes source, "[:pass]"
        first_enum = namespace.const_get("Record::Defs::Status")
        second_enum = namespace.const_get("Record::Defs::Second")
        (members + second).uniq.each do |raw|
          instance = root.from_h("value" => raw)
          expected = members.include?(raw) ? first_enum : second_enum
          assert_same expected.deserialize(raw), instance.value
          assert_equal({ "value" => raw }, instance.to_h)
          assert_same instance.value, root.from_h(instance.to_h).value
        end
        second_member = second_enum.deserialize(members.last)
        assert_equal(
          { "value" => members.last },
          root.new(value: second_member).to_h,
        )
        missing = members.first.is_a?(String) ? "missing" : 99
        assert_equal missing, root.from_h("value" => missing).value
      end
    end
  end

  def test_enum_and_plain_scalar_overlap
    orders = [true, false]
    [
      [%w[active inactive], "string", "missing"],
      [[1, 2], "integer", 99],
    ].each do |members, type, missing|
      orders.each do |enum_first|
        branches = [{ "$ref" => "#/$defs/status" }, { "type" => type }]
        branches.reverse! unless enum_first
        with_generated(
          { "anyOf" => branches },
          members:,
        ) do |root, source, _namespace|
          assert_includes source, "[:try,"
          assert_equal missing, root.from_h("value" => missing).value
          instance = root.from_h("value" => members.first)
          assert_equal members.first, instance.value.serialize
          assert_equal({ "value" => members.first }, instance.to_h)
        end
      end
    end
  end

  def test_unconstrained_alternative_keeps_unknown_values
    [true, {}].each do |alternative|
      with_generated(
        { "anyOf" => [{ "$ref" => "#/$defs/status" }, alternative] },
      ) do |root, source, _namespace|
        assert_includes source, "[:try,"
        assert_equal "missing", root.from_h("value" => "missing").value
      end
    end
  end

  def test_builtin_conflict
    [true, false].each do |enum_first|
      branches = [
        { "$ref" => "#/$defs/status" },
        { "type" => "string", "format" => "date" },
      ]
      branches.reverse! unless enum_first
      assert_raises(Schematrix::CoercionConflictError) do
        with_generated({ "anyOf" => branches }) { flunk "expected conflict" }
      end
    end
  end

  def test_try_rescues_only_key_error_and_uses_identity
    with_generated(
      { "enum" => %w[active inactive] },
    ) do |_root, _source, namespace|
      helper = namespace.const_get(:CoercionHelper)
      failing = Module.new
      failing.define_singleton_method(:coerce) { |_value| raise KeyError }
      value = Object.new
      assert_same value, helper.coerce_spec(value, [:try, [:coerce, failing]])
      failing = Module.new
      failing.define_singleton_method(:coerce) { |_value| raise ArgumentError }
      assert_raises(ArgumentError) do
        helper.coerce_spec(value, [:try, [:coerce, failing]])
      end
      changed = Object.new
      changed.define_singleton_method(:==) { |_other| true }
      converter = Module.new
      converter.define_singleton_method(:coerce) { |_value| changed }
      spec = [
        :union,
        [[:try, [:coerce, converter]], [:coerce, failing], [:pass]],
      ]
      assert_same changed, helper.coerce_spec(value, spec)
    end
  end

  private

  def with_generated(
    slot,
    members: %w[active inactive],
    second: nil,
    mode: :classes,
    catchall: false
  )
    Dir.mktmpdir do |directory|
      schema = {
        "type" => "object",
        "properties" => {
          "value" => slot,
        },
        "additionalProperties" => catchall,
        "$defs" => {
          "status" => {
            "enum" => members,
          },
        },
      }
      schema["$defs"]["second"] = { "enum" => second } if second
      path = File.join(directory, "record.json")
      File.write(path, JSON.generate(schema))
      objects = Schematrix::Compiler.new(enums_classes: true).compile([path])
      namespace = Module.new
      name = "EnumCoercions#{namespace.object_id}"
      Object.const_set(name, namespace)
      generator =
        Schematrix::Generators::PlainRuby.new(directory, name, enums: mode)
      enums =
        Schematrix::GENERATORS.fetch("plain_ruby_enums").new(directory, name)
      helper = Schematrix::Generators::AuxiliaryFiles.new(directory, name)
      helper.write_run_once(objects)
      require File.join(directory, "coercion_helper.rb")
      files =
        objects.map do |locator, node|
          (node.enum_class? ? enums : generator).write(locator, node)
        end
      files.each { |file| require file }
      source = File.read(File.join(directory, "record.rb"))
      yield namespace.const_get(:Record), source, namespace
    ensure
      Object.send(:remove_const, name) if name && Object.const_defined?(name)
    end
  end
end
