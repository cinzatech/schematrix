require_relative '../test_helper'

class TestAnnotations < Minitest::Test
  include SchematrixTestHelper
  def test_deprecated_property_plain_ruby
    assert_fixture('deprecated_property', 'plain_ruby')
  end

  def test_deprecated_property_rbs
    assert_fixture('deprecated_property', 'rbs')
  end

  def test_deprecated_property_sorbet_ruby
    assert_fixture('deprecated_property', 'sorbet_ruby')
  end

  def test_deprecated_property_rbi
    assert_fixture('deprecated_property', 'rbi')
  end

  def test_read_only_property_plain_ruby
    assert_fixture('read_only_property', 'plain_ruby')
  end

  def test_read_only_property_rbs
    assert_fixture('read_only_property', 'rbs')
  end

  def test_read_only_property_sorbet_ruby
    assert_fixture('read_only_property', 'sorbet_ruby')
  end

  def test_read_only_property_rbi
    assert_fixture('read_only_property', 'rbi')
  end

  def test_write_only_property_plain_ruby
    assert_fixture('write_only_property', 'plain_ruby')
  end

  def test_write_only_property_rbs
    assert_fixture('write_only_property', 'rbs')
  end

  def test_write_only_property_sorbet_ruby
    assert_fixture('write_only_property', 'sorbet_ruby')
  end

  def test_write_only_property_rbi
    assert_fixture('write_only_property', 'rbi')
  end

  def test_format_annotation_plain_ruby
    assert_fixture('format_annotation', 'plain_ruby')
  end

  def test_format_annotation_rbs
    assert_fixture('format_annotation', 'rbs')
  end

  def test_format_annotation_sorbet_ruby
    assert_fixture('format_annotation', 'sorbet_ruby')
  end

  def test_format_annotation_rbi
    assert_fixture('format_annotation', 'rbi')
  end

  def test_comment_ignored_plain_ruby
    assert_fixture('comment_ignored', 'plain_ruby')
  end

  def test_comment_ignored_rbs
    assert_fixture('comment_ignored', 'rbs')
  end

  def test_comment_ignored_sorbet_ruby
    assert_fixture('comment_ignored', 'sorbet_ruby')
  end

  def test_comment_ignored_rbi
    assert_fixture('comment_ignored', 'rbi')
  end

  def test_examples_annotation_plain_ruby
    assert_fixture('examples_annotation', 'plain_ruby')
  end

  def test_examples_annotation_rbs
    assert_fixture('examples_annotation', 'rbs')
  end

  def test_examples_annotation_sorbet_ruby
    assert_fixture('examples_annotation', 'sorbet_ruby')
  end

  def test_examples_annotation_rbi
    assert_fixture('examples_annotation', 'rbi')
  end
end
