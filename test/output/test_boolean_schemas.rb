require_relative "../test_helper"

require "tmpdir"

class TestBooleanSchemas < Minitest::Test
  include SchematrixTestHelper

  def test_true_schema_plain_ruby
    assert_fixture("true_schema", "plain_ruby")
  end

  def test_true_schema_rbs
    assert_fixture("true_schema", "rbs")
  end

  def test_true_schema_sorbet_ruby
    assert_fixture("true_schema", "sorbet_ruby")
  end

  def test_true_schema_rbi
    assert_fixture("true_schema", "rbi")
  end

  def test_false_property_plain_ruby
    assert_fixture("false_property", "plain_ruby")
  end

  def test_false_property_rbs
    assert_fixture("false_property", "rbs")
  end

  def test_false_property_sorbet_ruby
    assert_fixture("false_property", "sorbet_ruby")
  end

  def test_false_property_rbi
    assert_fixture("false_property", "rbi")
  end

  def test_items_false_plain_ruby
    assert_fixture("items_false", "plain_ruby")
  end

  def test_items_false_rbs
    assert_fixture("items_false", "rbs")
  end

  def test_items_false_sorbet_ruby
    assert_fixture("items_false", "sorbet_ruby")
  end

  def test_items_false_rbi
    assert_fixture("items_false", "rbi")
  end

  def test_const_value_plain_ruby
    assert_fixture("const_value", "plain_ruby")
  end

  def test_const_value_rbs
    assert_fixture("const_value", "rbs")
  end

  def test_const_value_sorbet_ruby
    assert_fixture("const_value", "sorbet_ruby")
  end

  def test_const_value_rbi
    assert_fixture("const_value", "rbi")
  end

  def test_ref_to_boolean_plain_ruby
    assert_fixture("ref_to_boolean", "plain_ruby")
  end

  def test_ref_to_boolean_rbs
    assert_fixture("ref_to_boolean", "rbs")
  end

  def test_ref_to_boolean_sorbet_ruby
    assert_fixture("ref_to_boolean", "sorbet_ruby")
  end

  def test_ref_to_boolean_rbi
    assert_fixture("ref_to_boolean", "rbi")
  end

  def test_document_that_is_just_true_produces_no_output
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "true.json")
      File.write(schema, "true")
      output = File.join(dir, "out")

      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, MODULE_NAME),
        ],
        input_files: [schema],
      )

      assert_empty Dir.glob("#{output}/**/*")
    end
  end
end
