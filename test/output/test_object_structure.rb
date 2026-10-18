require_relative "../test_helper"

class TestObjectStructure < Minitest::Test
  include SchematrixTestHelper

  def test_flat_object_plain_ruby
    assert_fixture("flat_object", "plain_ruby")
  end

  def test_flat_object_rbs
    assert_fixture("flat_object", "rbs")
  end

  def test_flat_object_sorbet_ruby
    assert_fixture("flat_object", "sorbet_ruby")
  end

  def test_flat_object_rbi
    assert_fixture("flat_object", "rbi")
  end

  def test_required_properties_plain_ruby
    assert_fixture("required_properties", "plain_ruby")
  end

  def test_required_properties_rbs
    assert_fixture("required_properties", "rbs")
  end

  def test_required_properties_sorbet_ruby
    assert_fixture("required_properties", "sorbet_ruby")
  end

  def test_required_properties_rbi
    assert_fixture("required_properties", "rbi")
  end

  def test_default_values_plain_ruby
    assert_fixture("default_values", "plain_ruby")
  end

  def test_default_values_rbs
    assert_fixture("default_values", "rbs")
  end

  def test_default_values_sorbet_ruby
    assert_fixture("default_values", "sorbet_ruby")
  end

  def test_default_values_rbi
    assert_fixture("default_values", "rbi")
  end

  def test_description_comment_plain_ruby
    assert_fixture("description_comment", "plain_ruby")
  end

  def test_description_comment_rbs
    assert_fixture("description_comment", "rbs")
  end

  def test_description_comment_sorbet_ruby
    assert_fixture("description_comment", "sorbet_ruby")
  end

  def test_description_comment_rbi
    assert_fixture("description_comment", "rbi")
  end

  def test_nested_object_plain_ruby
    assert_fixture("nested_object", "plain_ruby")
    assert_fixture("nested_object", "plain_ruby", path: "child")
  end

  def test_nested_object_rbs
    assert_fixture("nested_object", "rbs")
    assert_fixture("nested_object", "rbs", path: "child")
  end

  def test_nested_object_sorbet_ruby
    assert_fixture("nested_object", "sorbet_ruby")
    assert_fixture("nested_object", "sorbet_ruby", path: "child")
  end

  def test_nested_object_rbi
    assert_fixture("nested_object", "rbi")
    assert_fixture("nested_object", "rbi", path: "child")
  end

  def test_deeply_nested_plain_ruby
    assert_fixture("deeply_nested", "plain_ruby", path: "l1/l2")
  end

  def test_deeply_nested_rbs
    assert_fixture("deeply_nested", "rbs", path: "l1/l2")
  end

  def test_deeply_nested_sorbet_ruby
    assert_fixture("deeply_nested", "sorbet_ruby", path: "l1/l2")
  end

  def test_deeply_nested_rbi
    assert_fixture("deeply_nested", "rbi", path: "l1/l2")
  end

  def test_camel_to_snake_plain_ruby
    assert_fixture("camel_to_snake", "plain_ruby")
  end

  def test_camel_to_snake_rbs
    assert_fixture("camel_to_snake", "rbs")
  end

  def test_camel_to_snake_sorbet_ruby
    assert_fixture("camel_to_snake", "sorbet_ruby")
  end

  def test_camel_to_snake_rbi
    assert_fixture("camel_to_snake", "rbi")
  end

  def test_dollar_keyword_properties_plain_ruby
    assert_fixture("dollar_keyword_properties", "plain_ruby")
    assert_fixture(
      "dollar_keyword_properties",
      "plain_ruby",
      path: "defs",
      locator: defs_property_locator,
    )
    assert_fixture("dollar_keyword_properties", "plain_ruby", path: "Named")
  end

  def test_dollar_keyword_properties_rbs
    assert_fixture("dollar_keyword_properties", "rbs")
    assert_fixture(
      "dollar_keyword_properties",
      "rbs",
      path: "defs",
      locator: defs_property_locator,
    )
    assert_fixture("dollar_keyword_properties", "rbs", path: "Named")
  end

  private

  # A property named "$defs" is not the definitions container; the
  # helper's plain-name resolution cannot express it, so the locator
  # is spelled out.
  def defs_property_locator
    schema =
      File.expand_path(
        File.join(
          SchematrixTestHelper::FIXTURES_DIR,
          "dollar_keyword_properties",
          "schema.json",
        ),
      )
    "file://#{schema}#/properties/$defs"
  end
end
