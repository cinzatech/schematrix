require_relative '../test_helper'

class TestReferences < Minitest::Test
  include SchematrixTestHelper
  def test_ref_to_defs_plain_ruby
    assert_fixture('ref_to_defs', 'plain_ruby')
  end

  def test_ref_to_defs_rbs
    assert_fixture('ref_to_defs', 'rbs')
  end

  def test_ref_to_defs_sorbet_ruby
    assert_fixture('ref_to_defs', 'sorbet_ruby')
  end

  def test_ref_to_defs_rbi
    assert_fixture('ref_to_defs', 'rbi')
  end

  def test_ref_to_defs_object_plain_ruby
    assert_fixture('ref_to_defs_object', 'plain_ruby')
    assert_fixture('ref_to_defs_object', 'plain_ruby', path: 'Address')
  end

  def test_ref_to_defs_object_rbs
    assert_fixture('ref_to_defs_object', 'rbs')
    assert_fixture('ref_to_defs_object', 'rbs', path: 'Address')
  end

  def test_ref_to_defs_object_sorbet_ruby
    assert_fixture('ref_to_defs_object', 'sorbet_ruby')
    assert_fixture('ref_to_defs_object', 'sorbet_ruby', path: 'Address')
  end

  def test_ref_to_defs_object_rbi
    assert_fixture('ref_to_defs_object', 'rbi')
    assert_fixture('ref_to_defs_object', 'rbi', path: 'Address')
  end

  def test_ref_to_nested_defs_field_plain_ruby
    assert_fixture('ref_to_nested_defs_field', 'plain_ruby')
  end

  def test_ref_to_nested_defs_field_rbs
    assert_fixture('ref_to_nested_defs_field', 'rbs')
  end

  def test_ref_to_nested_defs_field_sorbet_ruby
    assert_fixture('ref_to_nested_defs_field', 'sorbet_ruby')
  end

  def test_ref_to_nested_defs_field_rbi
    assert_fixture('ref_to_nested_defs_field', 'rbi')
  end

  def test_ref_with_sibling_keywords_plain_ruby
    assert_fixture('ref_with_sibling_keywords', 'plain_ruby')
  end

  def test_ref_with_sibling_keywords_rbs
    assert_fixture('ref_with_sibling_keywords', 'rbs')
  end

  def test_ref_with_sibling_keywords_sorbet_ruby
    assert_fixture('ref_with_sibling_keywords', 'sorbet_ruby')
  end

  def test_ref_with_sibling_keywords_rbi
    assert_fixture('ref_with_sibling_keywords', 'rbi')
  end

  def test_multiple_refs_same_def_plain_ruby
    assert_fixture('multiple_refs_same_def', 'plain_ruby')
    assert_fixture('multiple_refs_same_def', 'plain_ruby', path: 'Address')
  end

  def test_multiple_refs_same_def_rbs
    assert_fixture('multiple_refs_same_def', 'rbs')
    assert_fixture('multiple_refs_same_def', 'rbs', path: 'Address')
  end

  def test_multiple_refs_same_def_sorbet_ruby
    assert_fixture('multiple_refs_same_def', 'sorbet_ruby')
    assert_fixture('multiple_refs_same_def', 'sorbet_ruby', path: 'Address')
  end

  def test_multiple_refs_same_def_rbi
    assert_fixture('multiple_refs_same_def', 'rbi')
    assert_fixture('multiple_refs_same_def', 'rbi', path: 'Address')
  end
end
