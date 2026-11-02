require_relative "test_helper"

class TestGeneratorNamespace < Minitest::Test
  def test_rejects_namespace_syntax_before_rendering
    invalid = [
      "Safe; raise 'injected'; module Unsafe",
      "Safe\nend\nraise 'injected'\nmodule Unsafe",
      "",
      "lowercase",
      "Safe::",
      "Safe:::Nested",
      "Safe::lowercase",
      "Safe # comment",
      " Safe",
      "Safe\n",
      nil,
    ]
    Schematrix::GENERATORS.each_value do |generator|
      invalid.each do |name|
        assert_raises(ArgumentError, "#{generator}: #{name.inspect}") do
          generator.new("/tmp", name)
        end
      end
    end
  end

  def test_accepts_constant_paths
    Schematrix::GENERATORS.each_value do |generator|
      %w[Example Example::Nested ::Example::Nested Example_2].each do |name|
        assert_equal name, generator.new("/tmp", name).module_name
      end
    end
  end
end
