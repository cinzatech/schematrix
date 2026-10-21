require_relative "test_helper"

class TestRequiredAfterOptional < Minitest::Test
  include SchematrixTestHelper

  # Ruby reports Method#parameters with required keywords first, and
  # sorbet-runtime validates the constructor sig against that order.
  # A required property after an optional one must therefore emit
  # first in the sig and the def, whichever way the document ordered
  # its properties.
  def test_sorbet_constructor_puts_required_kwargs_first
    assert_fixture("required_after_optional", "sorbet_ruby")
  end

  def test_plain_ruby_constructor_puts_required_kwargs_first
    assert_fixture("required_after_optional", "plain_ruby")
  end
end
