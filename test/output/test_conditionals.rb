require_relative '../test_helper'

class TestConditionals < Minitest::Test
  include SchematrixTestHelper
  def test_if_then_else_plain_ruby
    assert_fixture('if_then_else', 'plain_ruby')
  end

  def test_if_then_else_rbs
    assert_fixture('if_then_else', 'rbs')
  end

  def test_if_then_else_sorbet_ruby
    assert_fixture('if_then_else', 'sorbet_ruby')
  end

  def test_if_then_else_rbi
    assert_fixture('if_then_else', 'rbi')
  end
end
