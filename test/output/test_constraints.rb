require_relative '../test_helper'

class TestConstraints < Minitest::Test
  include SchematrixTestHelper

  def test_string_constraints_plain_ruby
    assert_fixture('string_constraints', 'plain_ruby')
  end

  def test_string_constraints_rbs
    assert_fixture('string_constraints', 'rbs')
  end

  def test_string_constraints_sorbet_ruby
    assert_fixture('string_constraints', 'sorbet_ruby')
  end

  def test_string_constraints_rbi
    assert_fixture('string_constraints', 'rbi')
  end

  def test_numeric_constraints_plain_ruby
    assert_fixture('numeric_constraints', 'plain_ruby')
  end

  def test_numeric_constraints_rbs
    assert_fixture('numeric_constraints', 'rbs')
  end

  def test_numeric_constraints_sorbet_ruby
    assert_fixture('numeric_constraints', 'sorbet_ruby')
  end

  def test_numeric_constraints_rbi
    assert_fixture('numeric_constraints', 'rbi')
  end

  def test_array_constraints_plain_ruby
    assert_fixture('array_constraints', 'plain_ruby')
  end

  def test_array_constraints_rbs
    assert_fixture('array_constraints', 'rbs')
  end

  def test_array_constraints_sorbet_ruby
    assert_fixture('array_constraints', 'sorbet_ruby')
  end

  def test_array_constraints_rbi
    assert_fixture('array_constraints', 'rbi')
  end
end
