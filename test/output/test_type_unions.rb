require_relative '../test_helper'

class TestTypeUnions < Minitest::Test
  include SchematrixTestHelper
  def test_type_as_array_plain_ruby
    assert_fixture('type_as_array', 'plain_ruby')
  end

  def test_type_as_array_rbs
    assert_fixture('type_as_array', 'rbs')
  end

  def test_type_as_array_sorbet_ruby
    assert_fixture('type_as_array', 'sorbet_ruby')
  end

  def test_type_as_array_rbi
    assert_fixture('type_as_array', 'rbi')
  end

  def test_nullable_type_plain_ruby
    assert_fixture('nullable_type', 'plain_ruby')
  end

  def test_nullable_type_rbs
    assert_fixture('nullable_type', 'rbs')
  end

  def test_nullable_type_sorbet_ruby
    assert_fixture('nullable_type', 'sorbet_ruby')
  end

  def test_nullable_type_rbi
    assert_fixture('nullable_type', 'rbi')
  end

  def test_object_or_boolean_plain_ruby
    assert_fixture('object_or_boolean', 'plain_ruby')
  end

  def test_object_or_boolean_rbs
    assert_fixture('object_or_boolean', 'rbs')
  end

  def test_object_or_boolean_sorbet_ruby
    assert_fixture('object_or_boolean', 'sorbet_ruby')
  end

  def test_object_or_boolean_rbi
    assert_fixture('object_or_boolean', 'rbi')
  end
end
