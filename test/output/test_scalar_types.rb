require_relative '../test_helper'

class TestScalarTypes < Minitest::Test
  include SchematrixTestHelper
  def test_string_property_plain_ruby
    assert_fixture('string_property', 'plain_ruby')
  end

  def test_string_property_rbs
    assert_fixture('string_property', 'rbs')
  end

  def test_string_property_sorbet_ruby
    assert_fixture('string_property', 'sorbet_ruby')
  end

  def test_string_property_rbi
    assert_fixture('string_property', 'rbi')
  end
  def test_integer_property_plain_ruby
    assert_fixture('integer_property', 'plain_ruby')
  end

  def test_integer_property_rbs
    assert_fixture('integer_property', 'rbs')
  end

  def test_integer_property_sorbet_ruby
    assert_fixture('integer_property', 'sorbet_ruby')
  end

  def test_integer_property_rbi
    assert_fixture('integer_property', 'rbi')
  end
  def test_number_property_plain_ruby
    assert_fixture('number_property', 'plain_ruby')
  end

  def test_number_property_rbs
    assert_fixture('number_property', 'rbs')
  end

  def test_number_property_sorbet_ruby
    assert_fixture('number_property', 'sorbet_ruby')
  end

  def test_number_property_rbi
    assert_fixture('number_property', 'rbi')
  end
  def test_boolean_property_plain_ruby
    assert_fixture('boolean_property', 'plain_ruby')
  end

  def test_boolean_property_rbs
    assert_fixture('boolean_property', 'rbs')
  end

  def test_boolean_property_sorbet_ruby
    assert_fixture('boolean_property', 'sorbet_ruby')
  end

  def test_boolean_property_rbi
    assert_fixture('boolean_property', 'rbi')
  end
  def test_null_property_plain_ruby
    assert_fixture('null_property', 'plain_ruby')
  end

  def test_null_property_rbs
    assert_fixture('null_property', 'rbs')
  end

  def test_null_property_sorbet_ruby
    assert_fixture('null_property', 'sorbet_ruby')
  end

  def test_null_property_rbi
    assert_fixture('null_property', 'rbi')
  end
end
