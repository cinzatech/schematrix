require_relative "../test_helper"

class TestFormattedScalars < Minitest::Test
  include SchematrixTestHelper

  def test_formatted_scalars_plain_ruby
    assert_fixture("formatted_scalars", "plain_ruby")
  end

  def test_formatted_scalars_sorbet_ruby
    assert_fixture("formatted_scalars", "sorbet_ruby")
  end

  def test_formatted_scalars_rbi
    assert_fixture("formatted_scalars", "rbi")
  end

  def test_formatted_scalars_rbs
    assert_fixture("formatted_scalars", "rbs")
  end

  def test_formatted_scalars_dsl_plain_ruby
    assert_fixture("formatted_scalars", "dsl_plain_ruby")
  end

  def test_formatted_scalars_dsl_sorbet_ruby
    assert_fixture("formatted_scalars", "dsl_sorbet_ruby")
  end

  def test_formatted_scalars_dsl_rbi
    assert_fixture("formatted_scalars", "dsl_rbi")
  end

  def test_formatted_scalars_dsl_rbs
    assert_fixture("formatted_scalars", "dsl_rbs")
  end
end
