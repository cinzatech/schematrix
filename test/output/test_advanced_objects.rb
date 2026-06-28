require_relative '../test_helper'

class TestAdvancedObjects < Minitest::Test
  include SchematrixTestHelper
  def test_additional_properties_schema_plain_ruby
    assert_fixture('additional_properties_schema', 'plain_ruby')
  end

  def test_additional_properties_schema_rbs
    assert_fixture('additional_properties_schema', 'rbs')
  end

  def test_additional_properties_schema_sorbet_ruby
    assert_fixture('additional_properties_schema', 'sorbet_ruby')
  end

  def test_additional_properties_schema_rbi
    assert_fixture('additional_properties_schema', 'rbi')
  end

  def test_pattern_properties_plain_ruby
    assert_fixture('pattern_properties', 'plain_ruby')
  end

  def test_pattern_properties_rbs
    assert_fixture('pattern_properties', 'rbs')
  end

  def test_pattern_properties_sorbet_ruby
    assert_fixture('pattern_properties', 'sorbet_ruby')
  end

  def test_pattern_properties_rbi
    assert_fixture('pattern_properties', 'rbi')
  end

  def test_property_names_plain_ruby
    assert_fixture('property_names', 'plain_ruby')
  end

  def test_property_names_rbs
    assert_fixture('property_names', 'rbs')
  end

  def test_property_names_sorbet_ruby
    assert_fixture('property_names', 'sorbet_ruby')
  end

  def test_property_names_rbi
    assert_fixture('property_names', 'rbi')
  end

  def test_dependent_schemas_plain_ruby
    assert_fixture('dependent_schemas', 'plain_ruby')
  end

  def test_dependent_schemas_rbs
    assert_fixture('dependent_schemas', 'rbs')
  end

  def test_dependent_schemas_sorbet_ruby
    assert_fixture('dependent_schemas', 'sorbet_ruby')
  end

  def test_dependent_schemas_rbi
    assert_fixture('dependent_schemas', 'rbi')
  end

  def test_object_constraints_plain_ruby
    assert_fixture('object_constraints', 'plain_ruby')
  end

  def test_object_constraints_rbs
    assert_fixture('object_constraints', 'rbs')
  end

  def test_object_constraints_sorbet_ruby
    assert_fixture('object_constraints', 'sorbet_ruby')
  end

  def test_object_constraints_rbi
    assert_fixture('object_constraints', 'rbi')
  end
end
