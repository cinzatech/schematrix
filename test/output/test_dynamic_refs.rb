require_relative '../test_helper'

class TestDynamicRefs < Minitest::Test
  include SchematrixTestHelper
  def test_dynamic_anchor_and_ref_plain_ruby
    assert_fixture('dynamic_anchor_and_ref', 'plain_ruby')
  end

  def test_dynamic_anchor_and_ref_rbs
    assert_fixture('dynamic_anchor_and_ref', 'rbs')
  end

  def test_dynamic_anchor_and_ref_sorbet_ruby
    assert_fixture('dynamic_anchor_and_ref', 'sorbet_ruby')
  end

  def test_dynamic_anchor_and_ref_rbi
    assert_fixture('dynamic_anchor_and_ref', 'rbi')
  end
end

class TestMetaschemaVocab < Minitest::Test
  include SchematrixTestHelper
  def test_content_encoding_plain_ruby
    assert_fixture('content_encoding', 'plain_ruby')
  end

  def test_content_encoding_rbs
    assert_fixture('content_encoding', 'rbs')
  end

  def test_content_encoding_sorbet_ruby
    assert_fixture('content_encoding', 'sorbet_ruby')
  end

  def test_content_encoding_rbi
    assert_fixture('content_encoding', 'rbi')
  end

  def test_vocabulary_keyword_plain_ruby
    assert_fixture('vocabulary_keyword', 'plain_ruby')
  end

  def test_vocabulary_keyword_rbs
    assert_fixture('vocabulary_keyword', 'rbs')
  end

  def test_vocabulary_keyword_sorbet_ruby
    assert_fixture('vocabulary_keyword', 'sorbet_ruby')
  end

  def test_vocabulary_keyword_rbi
    assert_fixture('vocabulary_keyword', 'rbi')
  end
end
