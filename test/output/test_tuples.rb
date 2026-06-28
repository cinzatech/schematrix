require_relative '../test_helper'

class TestTuples < Minitest::Test
  include SchematrixTestHelper
  def test_prefix_items_tuple_plain_ruby
    assert_fixture('prefix_items_tuple', 'plain_ruby')
  end

  def test_prefix_items_tuple_rbs
    assert_fixture('prefix_items_tuple', 'rbs')
  end

  def test_prefix_items_tuple_sorbet_ruby
    assert_fixture('prefix_items_tuple', 'sorbet_ruby')
  end

  def test_prefix_items_tuple_rbi
    assert_fixture('prefix_items_tuple', 'rbi')
  end

  def test_prefix_items_with_items_plain_ruby
    assert_fixture('prefix_items_with_items', 'plain_ruby')
  end

  def test_prefix_items_with_items_rbs
    assert_fixture('prefix_items_with_items', 'rbs')
  end

  def test_prefix_items_with_items_sorbet_ruby
    assert_fixture('prefix_items_with_items', 'sorbet_ruby')
  end

  def test_prefix_items_with_items_rbi
    assert_fixture('prefix_items_with_items', 'rbi')
  end
end
