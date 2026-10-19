require_relative "../test_helper"

class TestAdvancedObjects < Minitest::Test
  include SchematrixTestHelper

  def test_closed_shapes_plain_ruby
    assert_fixture("closed_shapes", "plain_ruby", closed_shapes: true)
  end

  def test_closed_shapes_rbs
    assert_fixture("closed_shapes", "rbs", closed_shapes: true)
  end

  def test_closed_shapes_sorbet_ruby
    assert_fixture("closed_shapes", "sorbet_ruby", closed_shapes: true)
  end

  def test_closed_shapes_rbi
    assert_fixture("closed_shapes", "rbi", closed_shapes: true)
  end

  def test_additional_properties_false_plain_ruby
    assert_fixture("additional_properties_false", "plain_ruby")
  end

  def test_additional_properties_false_rbs
    assert_fixture("additional_properties_false", "rbs")
  end

  def test_additional_properties_false_sorbet_ruby
    assert_fixture("additional_properties_false", "sorbet_ruby")
  end

  def test_additional_properties_false_rbi
    assert_fixture("additional_properties_false", "rbi")
  end

  def test_catch_all_only_schema_produces_no_class
    assert_empty compile_fixture("catch_all_only")
  end

  def test_additional_properties_schema_plain_ruby
    assert_fixture("additional_properties_schema", "plain_ruby")
  end

  def test_additional_properties_schema_rbs
    assert_fixture("additional_properties_schema", "rbs")
  end

  def test_additional_properties_schema_sorbet_ruby
    assert_fixture("additional_properties_schema", "sorbet_ruby")
  end

  def test_additional_properties_schema_rbi
    assert_fixture("additional_properties_schema", "rbi")
  end

  def test_additional_properties_union_plain_ruby
    assert_fixture("additional_properties_union", "plain_ruby")
  end

  def test_additional_properties_union_rbs
    assert_fixture("additional_properties_union", "rbs")
  end

  def test_additional_properties_union_sorbet_ruby
    assert_fixture("additional_properties_union", "sorbet_ruby")
  end

  def test_additional_properties_union_rbi
    assert_fixture("additional_properties_union", "rbi")
  end

  def test_additional_properties_union_ref_plain_ruby
    assert_fixture("additional_properties_union_ref", "plain_ruby")
    assert_fixture(
      "additional_properties_union_ref",
      "plain_ruby",
      path: "Thing",
    )
  end

  def test_additional_properties_union_ref_rbs
    assert_fixture("additional_properties_union_ref", "rbs")
    assert_fixture("additional_properties_union_ref", "rbs", path: "Thing")
  end

  def test_additional_properties_union_ref_sorbet_ruby
    assert_fixture("additional_properties_union_ref", "sorbet_ruby")
    assert_fixture(
      "additional_properties_union_ref",
      "sorbet_ruby",
      path: "Thing",
    )
  end

  def test_additional_properties_union_ref_rbi
    assert_fixture("additional_properties_union_ref", "rbi")
    assert_fixture("additional_properties_union_ref", "rbi", path: "Thing")
  end

  def test_pattern_properties_plain_ruby
    assert_fixture("pattern_properties", "plain_ruby")
  end

  def test_pattern_properties_rbs
    assert_fixture("pattern_properties", "rbs")
  end

  def test_pattern_properties_sorbet_ruby
    assert_fixture("pattern_properties", "sorbet_ruby")
  end

  def test_pattern_properties_rbi
    assert_fixture("pattern_properties", "rbi")
  end

  def test_property_names_plain_ruby
    assert_fixture("property_names", "plain_ruby")
  end

  def test_property_names_rbs
    assert_fixture("property_names", "rbs")
  end

  def test_property_names_sorbet_ruby
    assert_fixture("property_names", "sorbet_ruby")
  end

  def test_property_names_rbi
    assert_fixture("property_names", "rbi")
  end

  def test_dependent_schemas_plain_ruby
    assert_fixture("dependent_schemas", "plain_ruby")
  end

  def test_dependent_schemas_rbs
    assert_fixture("dependent_schemas", "rbs")
  end

  def test_dependent_schemas_sorbet_ruby
    assert_fixture("dependent_schemas", "sorbet_ruby")
  end

  def test_dependent_schemas_rbi
    assert_fixture("dependent_schemas", "rbi")
  end

  def test_object_constraints_plain_ruby
    assert_fixture("object_constraints", "plain_ruby")
  end

  def test_object_constraints_rbs
    assert_fixture("object_constraints", "rbs")
  end

  def test_object_constraints_sorbet_ruby
    assert_fixture("object_constraints", "sorbet_ruby")
  end

  def test_object_constraints_rbi
    assert_fixture("object_constraints", "rbi")
  end

  def test_map_values_ref_plain_ruby
    assert_fixture("map_values_ref", "plain_ruby")
    assert_fixture("map_values_ref", "plain_ruby", path: "value")
  end

  def test_map_values_ref_rbs
    assert_fixture("map_values_ref", "rbs")
    assert_fixture("map_values_ref", "rbs", path: "value")
  end

  def test_map_values_ref_sorbet_ruby
    assert_fixture("map_values_ref", "sorbet_ruby")
    assert_fixture("map_values_ref", "sorbet_ruby", path: "value")
  end

  def test_map_values_ref_rbi
    assert_fixture("map_values_ref", "rbi")
    assert_fixture("map_values_ref", "rbi", path: "value")
  end
end
