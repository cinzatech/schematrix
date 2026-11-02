require_relative "test_helper"
require "tmpdir"

class TestEnumCompilation < Minitest::Test
  def test_qualifying_members
    assert_equal %w[a b],
                 Schematrix::Schema.qualifying_enum_members(
                   ["a", nil, "b", "a"],
                 )
    assert_equal [1, 2],
                 Schematrix::Schema.qualifying_enum_members([1, 2, nil, 1])
    [
      nil,
      [],
      [nil],
      ["a", "a", nil],
      [true, false],
      [1.0, 2.0],
      [1, "a"],
      [{}, []],
    ].each do |values|
      assert_nil Schematrix::Schema.qualifying_enum_members(values)
    end
    refute_predicate Schematrix::Schema::Empty, :enum_class?
  end

  def test_inline_and_root_registration
    objects = compile("type" => "object", "properties" => { "status" => enum })
    assert_equal %w[/ /properties/status], objects.keys.sort
    assert_enum objects.fetch("/properties/status")
    assert_equal objects.fetch("/properties/status"),
                 objects.fetch("/").properties.fetch("status")

    root = compile(enum).fetch("/")
    assert_enum root
    assert_empty root.properties
  end

  def test_refs_register_only_the_definition_and_retain_annotations
    objects =
      compile(
        "type" => "object",
        "$defs" => {
          "status" => enum.merge("format" => "custom"),
          "alias" => {
            "$ref" => "#/$defs/status",
          },
        },
        "properties" => {
          "status" => {
            "$ref" => "#/$defs/alias",
            "title" => "State",
            "description" => "Current state",
            "default" => "a",
            "format" => "custom",
          },
          "second" => {
            "$ref" => "#/$defs/status",
          },
        },
      )
    assert_equal %w[/ /$defs/status], objects.keys.sort
    assert_enum objects.fetch("/$defs/status")
    slot = objects.fetch("/").properties.fetch("status")
    assert_enum slot
    assert_equal "/$defs/status", URI(slot.ref).fragment
    assert_equal "State", slot.title
    assert_equal "Current state", slot.description
    assert_equal "a", slot.default
    assert_equal "custom", slot.format
  end

  def test_nullable_enum_overrides_declared_type_even_at_ref_target
    target = { "type" => "object", "enum" => [1, nil, 2, 1] }
    root = compile(target).fetch("/")
    assert_equal Set["integer", "null"], root.type
    assert_equal [1, 2], root.enum
    assert_predicate root, :enum_class?
    refute_predicate root, :strictly_required?

    objects = with_slot({ "$ref" => "#/$defs/status" }, target:)
    slot = objects.fetch("/").properties.fetch("status")
    assert_equal root.type, slot.type
    assert_equal [1, 2], slot.enum
    assert_equal "/$defs/status", URI(slot.ref).fragment
    assert_equal %w[/ /$defs/status], objects.keys.sort
  end

  def test_exclusions_and_disabled_mode
    [
      { "enum" => ["a", nil, "a"] },
      { "enum" => [true, false] },
      { "enum" => [1.1, 2.2] },
      { "enum" => [1, "a"] },
      enum.merge("const" => "a"),
    ].each do |raw|
      objects = with_slot(raw)
      refute_predicate objects.fetch("/").properties.fetch("status"),
                       :enum_class?
      assert_equal ["/"], objects.keys
    end
    objects =
      compile(
        { "type" => "object", "properties" => { "status" => enum } },
        enums_classes: false,
      )
    assert_equal ["/"], objects.keys
    refute_predicate objects.fetch("/").properties.fetch("status"), :enum_class?
  end

  def test_sibling_enum_and_shape_constraints_do_not_keep_target_ref
    reference = { "$ref" => "#/$defs/status" }
    [
      { "enum" => %w[x y] },
      { "type" => "string" },
      { "const" => "a" },
      { "const" => nil },
    ].each do |sibling|
      objects = with_slot(reference.merge(sibling))
      slot = objects.fetch("/").properties.fetch("status")
      assert_nil slot.ref
      refute objects.key?("/$defs/status")
    end
    slot =
      with_slot({ "$ref" => "#/$defs/status", "enum" => %w[x y] })
        .fetch("/")
        .properties
        .fetch("status")
    assert_equal %w[x y], slot.enum
  end

  def test_reference_chain_does_not_skip_sibling_enum
    objects =
      with_slot(
        { "$ref" => "#/$defs/alias" },
        definitions: {
          "alias" => {
            "$ref" => "#/$defs/status",
            "enum" => %w[x y],
          },
        },
      )
    slot = objects.fetch("/").properties.fetch("status")
    assert_equal %w[x y], slot.enum
    assert_equal "/$defs/alias", URI(slot.ref).fragment
    assert_enum objects.fetch("/$defs/alias"), %w[x y]
    refute objects.key?("/$defs/status")
  end

  def test_property_folds_preserve_only_identical_enum_contributions
    %w[allOf anyOf oneOf].each do |keyword|
      same = folded_slot(keyword, enum, enum)
      assert_enum same
      [
        enum.merge("enum" => %w[x y]),
        { "type" => "string" },
        true,
      ].each do |other|
        slot = folded_slot(keyword, enum, other)
        refute_predicate slot, :enum_class?
        assert_nil slot.enum
        assert_nil slot.ref
      end
      assert_enum folded_slot(keyword, enum, false)
    end
  end

  def test_ref_folds_drop_enum_refs_but_keep_object_refs
    reference = { "$ref" => "#/$defs/status" }
    %w[allOf anyOf].each do |keyword|
      assert_enum folded_slot(keyword, reference, reference)
      slot = folded_slot(keyword, reference, { "type" => "string" })
      refute_predicate slot, :enum_class?
      assert_nil slot.ref
      assert_nil slot.enum
      object = { "$ref" => "#/$defs/object" }
      slot = folded_slot(keyword, reference, object)
      refute_predicate slot, :enum_class?
      assert_equal "/$defs/object", URI(slot.ref).fragment
    end
  end

  def test_value_allof_and_object_absorption_degrade_enum
    [
      { "type" => "string" },
      { "type" => "object", "properties" => { "x" => { "type" => "string" } } },
    ].each do |branch|
      slot =
        with_slot(enum.merge("allOf" => [branch]))
          .fetch("/")
          .properties
          .fetch("status")
      refute_predicate slot, :enum_class?
      assert_nil slot.enum
      assert_nil slot.ref
    end
    slot =
      with_slot(enum.merge("allOf" => [enum.merge("type" => "object")]))
        .fetch("/")
        .properties
        .fetch("status")
    assert_enum slot
    assert_equal Set["string"], slot.type
  end

  def test_root_enum_uses_value_allof_context
    assert_empty compile(enum.merge("allOf" => [{ "type" => "string" }]))
  end

  def test_array_item_folds_degrade_enum_metadata
    own = { "type" => "array", "items" => { "$ref" => "#/$defs/status" } }
    other = { "type" => "array", "items" => { "type" => "string" } }
    %w[allOf anyOf].each do |keyword|
      item = folded_slot(keyword, own, other).items
      refute_predicate item, :enum_class?
      assert_nil item.enum
      assert_nil item.ref
    end
  end

  def test_const_target_stays_scalar
    objects =
      with_slot(
        { "$ref" => "#/$defs/status" },
        target: enum.merge("const" => "a"),
      )
    assert_equal ["/"], objects.keys
    slot = objects.fetch("/").properties.fetch("status")
    refute_predicate slot, :enum_class?
    assert_nil slot.ref
  end

  def test_nested_null_const_omits_enum_in_both_modes
    raw = {
      "type" => "object",
      "properties" => {
        "nested" => {
          "type" => "object",
          "properties" => {
            "status" => enum.merge("const" => nil),
          },
        },
        "list" => {
          "type" => "array",
          "items" => enum.merge("const" => nil),
        },
      },
    }
    [true, false].each do |enums_classes|
      objects = compile(raw, enums_classes:)
      nested = objects.fetch("/properties/nested").properties.fetch("status")
      item = objects.fetch("/").properties.fetch("list").items
      [nested, item].each do |slot|
        refute_predicate slot, :enum_class?
        assert_nil slot.enum
      end
      assert_equal %w[/ /properties/nested], objects.keys.sort
    end
  end

  def test_null_const_ref_target_omits_enum
    objects =
      with_slot(
        { "$ref" => "#/$defs/status" },
        target: enum.merge("const" => nil),
      )
    assert_equal ["/"], objects.keys
    slot = objects.fetch("/").properties.fetch("status")
    refute_predicate slot, :enum_class?
    assert_nil slot.enum
    assert_nil slot.ref
  end

  def test_ref_branch_body_normalizes_null_const_without_changing_data_or_store
    data = {
      "const" => nil,
      "enum" => %w[a b],
      "properties" => {
        "x" => enum.merge("const" => nil),
      },
    }
    raw = {
      "type" => "object",
      "$defs" => {
        "body" => {
          "properties" => {
            "status" => enum.merge("const" => nil, "default" => data),
          },
        },
      },
      "allOf" => [{ "$ref" => "#/$defs/body" }],
    }
    Dir.mktmpdir do |dir|
      path = File.join(dir, "person.json")
      File.write(path, JSON.generate(raw))
      locator = URI("file://#{path}#/")
      store = Schematrix::DocumentStore.new
      stored = store.node_at(locator)
      objects =
        Schematrix::Compiler.new(store:, enums_classes: true).compile([path])
      slot = objects.fetch(locator.to_s).properties.fetch("status")
      refute_predicate slot, :enum_class?
      assert_nil slot.enum
      assert_equal data, slot.default
      assert_equal raw, stored
      assert_equal raw, store.node_at(locator)
    end
  end

  def test_enum_ref_inherits_target_format_and_local_format_wins
    target = enum.merge("format" => "date")
    reference = { "$ref" => "#/$defs/status" }
    objects = with_slot(reference, target:)
    slot = objects.fetch("/").properties.fetch("status")
    assert_enum slot
    assert_equal "date", slot.format
    assert_equal objects.fetch("/$defs/status").format, slot.format

    slot =
      with_slot(reference.merge("format" => "custom"), target:)
        .fetch("/")
        .properties
        .fetch("status")
    assert_enum slot
    assert_equal "custom", slot.format
  end

  def test_additional_properties_union_degrades_enum_metadata
    reference = { "$ref" => "#/$defs/status" }
    [enum, reference].each do |own|
      objects =
        compile(
          "type" => "object",
          "$defs" => {
            "status" => enum,
          },
          "properties" => {
            "id" => {
              "type" => "string",
            },
          },
          "additionalProperties" => own,
          "anyOf" => [{ "additionalProperties" => { "type" => "string" } }],
        )
      slot = objects.fetch("/").additional_properties
      refute_predicate slot, :enum_class?
      assert_nil slot.enum
      assert_nil slot.ref
    end
  end

  private

  def enum
    { "enum" => %w[a b] }
  end

  def assert_enum(schema, members = %w[a b])
    assert_predicate schema, :enum_class?
    assert_equal members, schema.enum
  end

  def with_slot(slot, target: enum, definitions: {})
    compile(
      "type" => "object",
      "$defs" => { "status" => target }.merge(definitions),
      "properties" => {
        "status" => slot,
      },
    )
  end

  def folded_slot(keyword, own, other)
    objects =
      compile(
        "type" => "object",
        "$defs" => {
          "status" => enum,
          "object" => {
            "type" => "object",
            "additionalProperties" => false,
          },
        },
        "properties" => {
          "status" => own,
        },
        keyword => [{ "properties" => { "status" => other } }],
      )
    objects.fetch("/").properties.fetch("status")
  end

  def compile(raw, options = {})
    enums_classes = options.fetch(:enums_classes, true)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "person.json")
      File.write(path, JSON.generate(raw))
      Schematrix::Compiler
        .new(enums_classes:)
        .compile([path])
        .to_h { |locator, schema| [URI(locator).fragment, schema] }
    end
  end
end
