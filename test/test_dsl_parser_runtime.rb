require_relative "test_helper"
require "prism"
require_relative "../lib/schematrix/generators/templates/dsl_parser_runtime"

module DslParserRuntimeTestNamespace
  module_eval(Schematrix::Generators::Templates::DslParserRuntime::BODY)
end

class TestDslParserRuntime < Minitest::Test
  Runtime = DslParserRuntimeTestNamespace

  def setup
    @child = { builder: "App::Dsl::Child", setters: {} }
    @child[:setters]["name"] = setter(:scalar, "name")
    @child[:setters]["age"] = setter(:scalar, "age")
    @contract = { builder: "App::Dsl::Person", setters: {} }
    {
      name: :scalar,
      address: :object,
      numbers: :array_scalars,
      people: :array_objects,
      mixed: :mixed_array,
      choice: :mixed_value,
      scores: :map_scalars,
      groups: :map_objects,
      extra: :extra_scalars,
      extra_object: :extra_objects,
    }.each do |name, kind|
      @contract[:setters][name.to_s] = setter(kind, name.to_s)
    end
  end

  def test_all_setter_shapes_and_repetition
    result = parse(<<~RUBY)
      name "first"
      name "last"
      address { name "A" }
      address { age 3 }
      numbers 1, 2
      numbers 3
      people { name "P" }
      mixed 4 do
        name "M"
      end
      mixed 5
      choice "ignored" do
        name "C"
      end
      choice { age 7 }
      scores "x", 1
      scores "x", 2
      groups("g") { name "G" }
      groups("g") { age 9 }
      extra "unknown", [true, false, nil, -2, 1.5]
      extra_object("nested") { name "N" }
    RUBY
    assert_equal "last", result["name"]
    assert_equal({ "name" => "A", "age" => 3 }, result["address"])
    assert_equal [1, 2, 3], result["numbers"]
    assert_equal [{ "name" => "P" }], result["people"]
    assert_equal [4, { "name" => "M" }, 5], result["mixed"]
    assert_equal({ "name" => "C", "age" => 7 }, result["choice"])
    assert_equal({ "x" => 2 }, result["scores"])
    assert_equal({ "g" => { "age" => 9 } }, result["groups"])
    assert_equal [true, false, nil, -2, 1.5], result["unknown"]
    assert_equal({ "name" => "N" }, result["nested"])
    assert_nil parse("choice")["choice"]
  end

  def test_wrappers_and_static_enum_resolution
    @contract[:setters]["name"][:value] = [
      :value,
      nil,
      nil,
      { "Outer::Values::Ready" => -> { "ready" } },
    ]
    source = <<~RUBY
      module Outer
        class Document
          extend App::Dsl::Person
          name Values::Ready
        end
      end
    RUBY
    assert_equal({ "name" => "ready" }, parse_source(source))
    assert_equal "ready", parse("name ::Outer::Values::Ready")["name"]
    refute Object.const_defined?(:Outer)
  end

  def test_literals_and_duplicate_hash_keys
    assert_equal({ "a" => 2 }, parse('name({"a" => 1, "a" => 2})')["name"])
    assert_equal({ "a" => 2 }, parse('name "a" => 2')["name"])
    assert_equal "a\nb", parse('name "a\\nb"')["name"]
  end

  def test_normalizers_and_readers_are_called_once
    calls = []
    reader =
      lambda do |node|
        calls << node.class
        "read"
      end
    normalizer =
      lambda do |literal|
        calls << literal
        "normalized"
      end
    @contract[:setters]["name"][:value] = [:value, reader, normalizer, {}]
    assert_equal "normalized", parse('name "literal"')["name"]
    assert_equal "read", parse("name Custom.make(1)")["name"]
    assert_equal ["literal", Prism::CallNode], calls
    parse("name __FILE__")
    assert_equal Prism::SourceFileNode, calls.last
  end

  def test_structured_specs_and_accumulated_tuple_position
    upper = [:value, nil, lambda(&:upcase), {}]
    lower = [:value, nil, lambda(&:downcase), {}]
    @contract[:setters]["mixed"][:value] = [:array, [upper, upper], lower]
    assert_equal ["A", { "name" => "B" }, "c"], parse(<<~RUBY)["mixed"]
      mixed "a" do
        name "B"
      end
      mixed "C"
    RUBY
    @contract[:setters]["name"][:value] = [
      :union,
      [upper, [:array, [], lower], [:map, upper]],
    ]
    assert_equal ["a"], parse('name ["A"]')["name"]
    assert_equal({ "a" => "B" }, parse('name({"a" => "b"})')["name"])
    assert_equal "A", parse('name "a"')["name"]
  end

  def test_error_metadata_and_cause
    original = ArgumentError.new("cannot normalize")
    @contract[:setters]["name"][:value] = [
      :value,
      nil,
      ->(_) { raise original },
      {},
    ]
    error = assert_raises(Runtime::ParseError) { parse('name "bad"') }
    assert_same original, error.cause
    assert_equal "input.rb", error.filename
    assert_equal 2, error.line
    assert_equal 6, error.column
    assert_equal "name", error.keyword
    assert_equal "cannot normalize", error.reason
  end

  def test_rejects_unsupported_entries
    [
      "",
      "App::Dsl::Person.build {}\n1",
      "Other.build {}",
      "App::Dsl::Person.build(1) {}",
      "App::Dsl::Person.build(&proc {})",
      "App::Dsl::Person.build { |x| }",
      "class X < Object; extend App::Dsl::Person; end",
      "class << Object; extend App::Dsl::Person; end",
      "BEGIN { raise 'must not execute' }; App::Dsl::Person.build {}",
      "END { raise 'must not execute' }; App::Dsl::Person.build {}",
      "module X; " \
        "module A; extend App::Dsl::Person; end; " \
        "module B; extend App::Dsl::Person; end; end",
      "module X; App::Dsl::Person.build {}; end",
      "module X; require 'x'; extend App::Dsl::Person; end",
      "module X; extend App::Dsl::Person; end; module Y; end",
      "App::Dsl::Person.build {}\n__END__\ndata",
      "App::Dsl::Person.build {",
    ].each do |source|
      assert_raises(Runtime::ParseError, source) { parse_source(source) }
    end
  end

  def test_rejects_unsupported_statements_values_and_signatures
    [
      "require 'x'",
      "self.name 'x'",
      "if true; name 'x'; end",
      "def x; end",
      "x = 1",
      "name \"\#{1}\"",
      "name :symbol",
      "name /regexp/",
      "name 1r",
      "name 1i",
      "name __LINE__",
      "name Unknown::Value",
      "name foo",
      "name [*[]]",
      "name({**{}})",
      "name(a: 1)",
      "name(*[])",
      "name",
      "name 1, 2",
      "name(1) {}",
      "address",
      "address(1) {}",
      "address { |x| name 'x' }",
      "numbers(1) {}",
      "people 1",
      "scores 'x'",
      "groups('x', 1) {}",
      "choice 1, 2",
      "choice(x = 1) { name 'A' }",
      "extra 'x'",
      "extra_object 'x'",
      "name 1 rescue nil",
      "address do; name 'x'; ensure; name 'y'; end",
    ].each do |source|
      assert_raises(Runtime::ParseError, source) { parse(source) }
    end
  end

  def test_enum_and_reader_union_branches
    calls = []
    reader =
      lambda do |node|
        calls << node.class
        "read"
      end
    enum = { "Values::Ready" => -> { "ready" } }
    @contract[:setters]["name"][:value] = [
      :union,
      [[:map, nil], [:value, reader, nil, enum]],
    ]
    assert_equal "ready", parse("name Values::Ready")["name"]
    assert_empty calls
    assert_equal "read", parse("name Custom.make")["name"]
    assert_equal [Prism::CallNode], calls
  end

  def test_union_readers_use_first_generated_callback
    first = ->(_) { "first" }
    second = ->(_) { flunk "second reader must not run" }
    @contract[:setters]["name"][:value] = [
      :union,
      [[:value, first, nil, {}], [:value, second, nil, {}]],
    ]
    assert_equal "first", parse("name Custom.make")["name"]
  end

  def test_union_normalizers_skip_identity_results
    identity = ->(value) { value }
    convert = lambda(&:upcase)
    unused = ->(_) { flunk "later normalizer must not run" }
    @contract[:setters]["name"][:value] = [
      :union,
      [
        [:value, nil, identity, {}],
        [:value, nil, convert, {}],
        [:value, nil, unused, {}],
      ],
    ]
    assert_equal "A", parse('name "a"')["name"]
  end

  def test_mixed_block_does_not_normalize_ignored_literal
    normalizer = ->(_) { flunk "ignored values must not be normalized" }
    @contract[:setters]["choice"][:value] = [:value, nil, normalizer, {}]
    assert_equal(
      { "name" => "A" },
      parse('choice("ignored") { name "A" }')["choice"],
    )
  end

  def test_negative_numbers_are_primitive_literals
    assert_equal [-12, -1.5], parse("numbers -12, -1.5")["numbers"]
  end

  def test_columns_count_characters_not_bytes
    error = assert_raises(Runtime::ParseError) { parse('name "é"; unknown 1') }
    assert_equal 2, error.line
    assert_equal 11, error.column
  end

  def test_reader_failures_preserve_the_cause
    original = ArgumentError.new("reader rejected expression")
    reader = ->(_) { raise original }
    @contract[:setters]["name"][:value] = [:value, reader, nil, {}]
    error = assert_raises(Runtime::ParseError) { parse("name Custom.make") }
    assert_same original, error.cause
    assert_equal "name", error.keyword
    assert_equal 2, error.line
  end

  def test_normalizers_do_not_enable_unsupported_syntax
    normalizer = ->(_) { flunk "unsupported syntax reached normalizer" }
    @contract[:setters]["name"][:value] = [:value, nil, normalizer, {}]
    ["name :symbol", "name __FILE__", "name Custom.make"].each do |source|
      assert_raises(Runtime::ParseError) { parse(source) }
    end
  end

  def test_container_collisions_are_parse_errors
    assert_raises(Runtime::ParseError) do
      parse('extra "numbers", 1; numbers 2')
    end
    assert_raises(Runtime::ParseError) do
      parse('extra "scores", 1; scores "x", 2')
    end
    assert_equal(
      { "name" => "A" },
      parse('extra "address", 1; address { name "A" }')["address"],
    )
  end

  private

  def setter(kind, key)
    { kind: kind, key: key, value: nil, child: -> { @child } }
  end

  def parse(body)
    parse_source("App::Dsl::Person.build do\n#{body}\nend")
  end

  def parse_source(source)
    Runtime.parse(source, filename: "input.rb", contract: @contract)
  end
end
