require_relative "../test_helper"

class TestDslBuilders < Minitest::Test
  include SchematrixTestHelper

  # The items class of array_of_objects: fixture_locator maps every
  # segment through properties/, so array item locators are built
  # explicitly.
  def array_of_objects_items_locator
    schema = File.join(FIXTURES_DIR, "array_of_objects", "schema.json")
    "file://#{File.expand_path(schema)}#/properties/entries/items"
  end

  def test_nested_object_dsl_plain_ruby
    assert_fixture("nested_object", "dsl_plain_ruby")
    assert_fixture("nested_object", "dsl_plain_ruby", path: "child")
  end

  def test_nested_object_dsl_sorbet_ruby
    assert_fixture("nested_object", "dsl_sorbet_ruby")
    assert_fixture("nested_object", "dsl_sorbet_ruby", path: "child")
  end

  def test_nested_object_dsl_rbi
    assert_fixture("nested_object", "dsl_rbi")
    assert_fixture("nested_object", "dsl_rbi", path: "child")
  end

  def test_nested_object_dsl_rbs
    assert_fixture("nested_object", "dsl_rbs")
    assert_fixture("nested_object", "dsl_rbs", path: "child")
  end

  def test_array_of_objects_dsl_plain_ruby
    assert_fixture("array_of_objects", "dsl_plain_ruby")
    assert_fixture(
      "array_of_objects",
      "dsl_plain_ruby",
      path: "entries/items",
      locator: array_of_objects_items_locator,
    )
  end

  def test_array_of_objects_dsl_sorbet_ruby
    assert_fixture("array_of_objects", "dsl_sorbet_ruby")
    assert_fixture(
      "array_of_objects",
      "dsl_sorbet_ruby",
      path: "entries/items",
      locator: array_of_objects_items_locator,
    )
  end

  def test_array_of_objects_dsl_rbi
    assert_fixture("array_of_objects", "dsl_rbi")
    assert_fixture(
      "array_of_objects",
      "dsl_rbi",
      path: "entries/items",
      locator: array_of_objects_items_locator,
    )
  end

  def test_array_of_objects_dsl_rbs
    assert_fixture("array_of_objects", "dsl_rbs")
    assert_fixture(
      "array_of_objects",
      "dsl_rbs",
      path: "entries/items",
      locator: array_of_objects_items_locator,
    )
  end

  def test_map_values_ref_dsl_plain_ruby
    assert_fixture("map_values_ref", "dsl_plain_ruby")
    assert_fixture("map_values_ref", "dsl_plain_ruby", path: "value")
  end

  def test_map_values_ref_dsl_sorbet_ruby
    assert_fixture("map_values_ref", "dsl_sorbet_ruby")
    assert_fixture("map_values_ref", "dsl_sorbet_ruby", path: "value")
  end

  def test_map_values_ref_dsl_rbi
    assert_fixture("map_values_ref", "dsl_rbi")
    assert_fixture("map_values_ref", "dsl_rbi", path: "value")
  end

  def test_map_values_ref_dsl_rbs
    assert_fixture("map_values_ref", "dsl_rbs")
    assert_fixture("map_values_ref", "dsl_rbs", path: "value")
  end

  def test_additional_properties_schema_dsl_plain_ruby
    assert_fixture("additional_properties_schema", "dsl_plain_ruby")
  end

  def test_additional_properties_schema_dsl_sorbet_ruby
    assert_fixture("additional_properties_schema", "dsl_sorbet_ruby")
  end

  def test_additional_properties_schema_dsl_rbi
    assert_fixture("additional_properties_schema", "dsl_rbi")
  end

  def test_additional_properties_schema_dsl_rbs
    assert_fixture("additional_properties_schema", "dsl_rbs")
  end

  def test_additional_properties_false_dsl_plain_ruby
    assert_fixture("additional_properties_false", "dsl_plain_ruby")
  end

  def test_additional_properties_false_dsl_sorbet_ruby
    assert_fixture("additional_properties_false", "dsl_sorbet_ruby")
  end

  def test_additional_properties_false_dsl_rbi
    assert_fixture("additional_properties_false", "dsl_rbi")
  end

  def test_additional_properties_false_dsl_rbs
    assert_fixture("additional_properties_false", "dsl_rbs")
  end

  def test_type_as_array_dsl_plain_ruby
    assert_fixture("type_as_array", "dsl_plain_ruby")
  end

  def test_type_as_array_dsl_sorbet_ruby
    assert_fixture("type_as_array", "dsl_sorbet_ruby")
  end

  def test_type_as_array_dsl_rbi
    assert_fixture("type_as_array", "dsl_rbi")
  end

  def test_type_as_array_dsl_rbs
    assert_fixture("type_as_array", "dsl_rbs")
  end

  def test_union_array_items_dsl_plain_ruby
    assert_fixture("union_array_items", "dsl_plain_ruby")
  end

  def test_union_array_items_dsl_sorbet_ruby
    assert_fixture("union_array_items", "dsl_sorbet_ruby")
  end

  def test_union_array_items_dsl_rbi
    assert_fixture("union_array_items", "dsl_rbi")
  end

  def test_union_array_items_dsl_rbs
    assert_fixture("union_array_items", "dsl_rbs")
  end

  def test_default_values_dsl_plain_ruby
    assert_fixture("default_values", "dsl_plain_ruby")
  end

  def test_default_values_dsl_sorbet_ruby
    assert_fixture("default_values", "dsl_sorbet_ruby")
  end

  def test_default_values_dsl_rbi
    assert_fixture("default_values", "dsl_rbi")
  end

  def test_default_values_dsl_rbs
    assert_fixture("default_values", "dsl_rbs")
  end

  def test_dsl_mixed_value_dsl_plain_ruby
    assert_fixture("dsl_mixed_value", "dsl_plain_ruby")
    assert_fixture("dsl_mixed_value", "dsl_plain_ruby", path: "option")
  end

  def test_dsl_mixed_value_dsl_sorbet_ruby
    assert_fixture("dsl_mixed_value", "dsl_sorbet_ruby")
    assert_fixture("dsl_mixed_value", "dsl_sorbet_ruby", path: "option")
  end

  def test_dsl_mixed_value_dsl_rbi
    assert_fixture("dsl_mixed_value", "dsl_rbi")
    assert_fixture("dsl_mixed_value", "dsl_rbi", path: "option")
  end

  def test_dsl_mixed_value_dsl_rbs
    assert_fixture("dsl_mixed_value", "dsl_rbs")
    assert_fixture("dsl_mixed_value", "dsl_rbs", path: "option")
  end
end
