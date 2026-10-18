require_relative "../test_helper"

class TestBooleanSchemas < Minitest::Test
  include SchematrixTestHelper

  def test_true_schema_plain_ruby
    assert_fixture("true_schema", "plain_ruby")
  end

  def test_true_schema_rbs
    assert_fixture("true_schema", "rbs")
  end

  def test_true_schema_sorbet_ruby
    assert_fixture("true_schema", "sorbet_ruby")
  end

  def test_true_schema_rbi
    assert_fixture("true_schema", "rbi")
  end

  def test_false_property_plain_ruby
    assert_fixture("false_property", "plain_ruby")
  end

  def test_false_property_rbs
    assert_fixture("false_property", "rbs")
  end

  def test_false_property_sorbet_ruby
    assert_fixture("false_property", "sorbet_ruby")
  end

  def test_false_property_rbi
    assert_fixture("false_property", "rbi")
  end

  def test_items_false_plain_ruby
    assert_fixture("items_false", "plain_ruby")
  end

  def test_items_false_rbs
    assert_fixture("items_false", "rbs")
  end

  def test_items_false_sorbet_ruby
    assert_fixture("items_false", "sorbet_ruby")
  end

  def test_items_false_rbi
    assert_fixture("items_false", "rbi")
  end

  def test_const_value_plain_ruby
    assert_fixture("const_value", "plain_ruby")
  end

  def test_const_value_rbs
    assert_fixture("const_value", "rbs")
  end

  def test_const_value_sorbet_ruby
    assert_fixture("const_value", "sorbet_ruby")
  end

  def test_const_value_rbi
    assert_fixture("const_value", "rbi")
  end
end
