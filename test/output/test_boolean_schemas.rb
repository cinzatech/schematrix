require_relative '../test_helper'

class TestBooleanSchemas < Minitest::Test
  include SchematrixTestHelper
  def test_true_schema_plain_ruby
    assert_fixture('true_schema', 'plain_ruby')
  end

  def test_true_schema_rbs
    assert_fixture('true_schema', 'rbs')
  end

  def test_true_schema_sorbet_ruby
    assert_fixture('true_schema', 'sorbet_ruby')
  end

  def test_true_schema_rbi
    assert_fixture('true_schema', 'rbi')
  end

  def test_const_value_plain_ruby
    assert_fixture('const_value', 'plain_ruby')
  end

  def test_const_value_rbs
    assert_fixture('const_value', 'rbs')
  end

  def test_const_value_sorbet_ruby
    assert_fixture('const_value', 'sorbet_ruby')
  end

  def test_const_value_rbi
    assert_fixture('const_value', 'rbi')
  end
end
