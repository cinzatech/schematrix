require_relative '../test_helper'

class TestArrays < Minitest::Test
  include SchematrixTestHelper
  def test_array_of_strings_plain_ruby
    assert_fixture('array_of_strings', 'plain_ruby')
  end

  def test_array_of_strings_rbs
    assert_fixture('array_of_strings', 'rbs')
  end

  def test_array_of_strings_sorbet_ruby
    assert_fixture('array_of_strings', 'sorbet_ruby')
  end

  def test_array_of_strings_rbi
    assert_fixture('array_of_strings', 'rbi')
  end
  def test_array_of_integers_plain_ruby
    assert_fixture('array_of_integers', 'plain_ruby')
  end

  def test_array_of_integers_rbs
    assert_fixture('array_of_integers', 'rbs')
  end

  def test_array_of_integers_sorbet_ruby
    assert_fixture('array_of_integers', 'sorbet_ruby')
  end

  def test_array_of_integers_rbi
    assert_fixture('array_of_integers', 'rbi')
  end
  def test_array_of_objects_plain_ruby
    assert_fixture('array_of_objects', 'plain_ruby')
  end

  def test_array_of_objects_rbs
    assert_fixture('array_of_objects', 'rbs')
  end

  def test_array_of_objects_sorbet_ruby
    assert_fixture('array_of_objects', 'sorbet_ruby')
  end

  def test_array_of_objects_rbi
    assert_fixture('array_of_objects', 'rbi')
  end
  def test_array_no_items_plain_ruby
    assert_fixture('array_no_items', 'plain_ruby')
  end

  def test_array_no_items_rbs
    assert_fixture('array_no_items', 'rbs')
  end

  def test_array_no_items_sorbet_ruby
    assert_fixture('array_no_items', 'sorbet_ruby')
  end

  def test_array_no_items_rbi
    assert_fixture('array_no_items', 'rbi')
  end
end
