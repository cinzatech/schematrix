require_relative "test_helper"
require "tmpdir"

class TestCompilationBudget < Minitest::Test
  def test_repeated_inline_references_exhaust_shared_budget
    [
      { "type" => "string" },
      {
        "oneOf" => [
          { "type" => "object", "additionalProperties" => false },
          { "type" => "string" },
        ],
      },
    ].each do |leaf|
      with_schema(reference_graph(12, leaf)) do |path|
        assert_raises(Schematrix::CompilationLimitError) do
          Schematrix::Compiler.new(max_compilation_work: 20_000).compile([path])
        end
      end
    end
  end

  def test_object_composition_also_consumes_budget
    schema =
      reference_graph(
        12,
        { "properties" => { "x" => { "type" => "string" } } },
        "allOf",
      )
    with_schema(schema) do |path|
      assert_raises(Schematrix::CompilationLimitError) do
        Schematrix::Compiler.new(max_compilation_work: 20_000).compile([path])
      end
    end
  end

  def test_shallow_shared_references_compile
    with_schema(reference_graph(2, { "type" => "string" })) do |path|
      refute_empty Schematrix::Compiler.new.compile([path])
    end
  end

  def test_budget_is_shared_across_roots
    with_schema(
      { "type" => "object", "additionalProperties" => false },
    ) do |first|
      with_schema(
        { "type" => "object", "additionalProperties" => false },
      ) do |second|
        budget = Schematrix::CompilationBudget.new(10_000)
        compiler = Schematrix::Compiler.new
        compiler.instance_variable_set(:@budget, budget)
        compiler.compile([first])
        used = 10_000 - budget.remaining
        [first, second].each do |path|
          objects =
            Schematrix::Compiler.new(max_compilation_work: used).compile([path])
          refute_empty objects
        end
        assert_raises(Schematrix::CompilationLimitError) do
          Schematrix::Compiler.new(max_compilation_work: used).compile(
            [first, second],
          )
        end
      end
    end
  end

  def test_exhaustion_precedes_output
    with_schema(reference_graph(12, { "type" => "string" })) do |path|
      output = File.join(File.dirname(path), "output")
      generator =
        Schematrix::Generators::PlainRuby.new(output, "BudgetRegression")
      assert_raises(Schematrix::CompilationLimitError) do
        Schematrix.generate(
          input_files: [path],
          generators: [generator],
          max_compilation_work: 20_000,
        )
      end
      refute_path_exists output
      assert_raises(Schematrix::CompilationLimitError) do
        Schematrix::Compiler.new(max_compilation_work: 1).compile([path])
      end
    end
  end

  def test_default_limit_stops_expansion
    with_schema(reference_graph(12, { "type" => "string" })) do |path|
      assert_raises(Schematrix::CompilationLimitError) do
        Schematrix::Compiler.new.compile([path])
      end
    end
  end

  def test_exhaustion_precedes_model_conversion
    visitor =
      Schematrix::Visitor.new(
        URI("file:///schema.json#/"),
        Schematrix::DocumentStore.new,
        budget: Schematrix::CompilationBudget.new(3),
      )
    original = Schematrix::Meta::Schema.method(:from_h)
    Schematrix::Meta::Schema.define_singleton_method(:from_h) do |*|
      raise "model conversion must not start"
    end
    assert_raises(Schematrix::CompilationLimitError) do
      visitor.compile("properties" => 100.times.to_h { |i| [i.to_s, true] })
    end
  ensure
    if original
      Schematrix::Meta::Schema.define_singleton_method(:from_h, original)
    end
  end

  def test_invalid_limits_are_rejected
    [0, -1, nil, 1.5].each do |limit|
      assert_raises(ArgumentError) do
        Schematrix::Compiler.new(max_compilation_work: limit)
      end
    end
  end

  private

  def reference_graph(depth, leaf, keyword = "anyOf")
    definitions = { "n0" => leaf }
    1.upto(depth) do |index|
      definitions["n#{index}"] = {
        keyword => Array.new(2) { { "$ref" => "#/$defs/n#{index - 1}" } },
      }
    end
    {
      "type" => "object",
      "properties" => {
        "value" => {
          "$ref" => "#/$defs/n#{depth}",
        },
      },
      "$defs" => definitions,
    }
  end

  def with_schema(schema)
    Dir.mktmpdir do |dir|
      path = File.join(dir, "schema.json")
      File.write(path, JSON.generate(schema))
      yield path
    end
  end
end
