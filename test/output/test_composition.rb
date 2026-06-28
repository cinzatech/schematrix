require_relative '../test_helper'

class TestComposition < Minitest::Test
  include SchematrixTestHelper
  def test_all_of_merge_plain_ruby
    assert_fixture('all_of_merge', 'plain_ruby')
  end

  def test_all_of_merge_rbs
    assert_fixture('all_of_merge', 'rbs')
  end

  def test_all_of_merge_sorbet_ruby
    assert_fixture('all_of_merge', 'sorbet_ruby')
  end

  def test_all_of_merge_rbi
    assert_fixture('all_of_merge', 'rbi')
  end

  def test_all_of_refs_plain_ruby
    assert_fixture('all_of_refs', 'plain_ruby')
  end

  def test_all_of_refs_rbs
    assert_fixture('all_of_refs', 'rbs')
  end

  def test_all_of_refs_sorbet_ruby
    assert_fixture('all_of_refs', 'sorbet_ruby')
  end

  def test_all_of_refs_rbi
    assert_fixture('all_of_refs', 'rbi')
  end

  def test_any_of_scalars_plain_ruby
    assert_fixture('any_of_scalars', 'plain_ruby')
  end

  def test_any_of_scalars_rbs
    assert_fixture('any_of_scalars', 'rbs')
  end

  def test_any_of_scalars_sorbet_ruby
    assert_fixture('any_of_scalars', 'sorbet_ruby')
  end

  def test_any_of_scalars_rbi
    assert_fixture('any_of_scalars', 'rbi')
  end

  def test_any_of_with_ref_plain_ruby
    assert_fixture('any_of_with_ref', 'plain_ruby')
  end

  def test_any_of_with_ref_rbs
    assert_fixture('any_of_with_ref', 'rbs')
  end

  def test_any_of_with_ref_sorbet_ruby
    assert_fixture('any_of_with_ref', 'sorbet_ruby')
  end

  def test_any_of_with_ref_rbi
    assert_fixture('any_of_with_ref', 'rbi')
  end
end
