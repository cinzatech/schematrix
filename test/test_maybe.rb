require_relative "test_helper"

require "tmpdir"

# A project Maybe with the four methods the generator checks, for the
# supplied-maybe tests.
module ProjectMaybe
  def self.from(value) = [:present, value]

  def self.empty = :absent

  def present? = raise NotImplementedError

  def when_present(...) = raise NotImplementedError
end

# A supplied Maybe with a generic surface, as a Sorbet-generic module
# answers `[]`; the generator only checks that application resolves.
module ProjectGenericMaybe
  def self.[](_) = nil

  def self.from(value) = [:present, value]

  def self.empty = :absent

  def present? = raise NotImplementedError

  def when_present(...) = raise NotImplementedError
end

class TestMaybe < Minitest::Test
  include SchematrixTestHelper

  def test_maybe_optionals_generate_golden_output
    %w[plain_ruby sorbet_ruby rbi rbs].each do |generator|
      assert_fixture("maybe", generator, optionals: :maybe)
    end
  end

  def test_partial_generators_generate_golden_output
    %w[
      partial_plain_ruby
      partial_sorbet_ruby
      partial_rbi
      partial_rbs
    ].each { |generator| assert_fixture("maybe", generator) }
  end

  def test_maybe_optionals_leave_the_default_output_unchanged
    expected = generate_fixture("maybe", "sorbet_ruby")
    actual = generate_fixture("maybe", "sorbet_ruby", optionals: :nilable)

    assert_equal expected, actual
    refute_match(/Maybe/, expected)
  end

  def test_generated_maybe_renders_every_flavor
    assert_maybe_golden("maybe", :sorbet, "maybe_sorbet.rb")
    assert_maybe_golden("maybe", :plain, "maybe_plain.rb")
    assert_maybe_golden("maybe", :rbs, "maybe_rbs.rbs")
    assert_maybe_golden("maybe", :rbi, "maybe_rbi.rbi")
  end

  MAYBE_MODULE_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "age": { "type": "integer" }
      },
      "required": ["name"]
    }
  JSON

  def test_pipeline_writes_the_generated_maybe_once_per_directory
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "schema.json")
      File.write(schema, MAYBE_MODULE_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(
            output,
            "Gen",
            optionals: :maybe,
          ),
          Schematrix::Generators::PartialPlainRuby.new(output, "Gen"),
        ],
        input_files: [schema],
      )

      assert_equal(
        ["maybe.rb"],
        Dir.glob("#{output}/maybe.*").map { |p| File.basename(p) },
      )
      maybe = File.read(File.join(output, "maybe.rb"))
      assert_includes maybe, "module Gen"
      assert_includes maybe, "module Maybe"
    end
  end

  def test_pipeline_writes_no_maybe_without_the_option
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "schema.json")
      File.write(schema, MAYBE_MODULE_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [Schematrix::Generators::PlainRuby.new(output, "Gen")],
        input_files: [schema],
      )

      assert_empty Dir.glob("#{output}/maybe.*")
    end
  end

  def test_pipeline_writes_no_maybe_with_a_supplied_maybe
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "schema.json")
      File.write(schema, MAYBE_MODULE_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(
            output,
            "Gen",
            optionals: :maybe,
            maybe: ProjectMaybe,
          ),
        ],
        input_files: [schema],
      )

      assert_empty Dir.glob("#{output}/maybe.*")
    end
  end

  def test_supplied_maybe_must_answer_the_contract
    assert_raises(ArgumentError) do
      Schematrix::Generators::PlainRuby.new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe: Object,
      )
    end

    assert_raises(ArgumentError) do
      Schematrix::Generators::PlainRuby.new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe:
          Class.new do
            def self.from(value) = value

            def self.empty = nil
          end,
      )
    end
  end

  def test_supplied_maybe_must_be_a_named_module
    anonymous =
      Class.new do
        def self.from(value) = value

        def self.empty = nil

        def present? = true

        def when_present(...) = nil
      end
    assert_raises(ArgumentError) do
      Schematrix::Generators::PlainRuby.new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe: anonymous,
      )
    end

    assert_raises(ArgumentError) do
      Schematrix::Generators::PlainRuby.new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe: Object.new,
      )
    end
  end

  def test_typed_generators_require_a_generic_supplied_maybe
    error =
      assert_raises(ArgumentError) do
        Schematrix::Generators::SorbetRuby.new(
          "/tmp",
          "Gen",
          optionals: :maybe,
          maybe: ProjectMaybe,
        )
      end
    assert_includes error.message, "apply its value type"

    Schematrix::Generators::PlainRuby.new(
      "/tmp",
      "Gen",
      optionals: :maybe,
      maybe: ProjectMaybe,
    )
    Schematrix::Generators::SorbetRuby.new(
      "/tmp",
      "Gen",
      optionals: :maybe,
      maybe: ProjectGenericMaybe,
    )
  end

  def test_signature_formats_accept_a_plain_supplied_maybe
    %w[Rbs Rbi PartialRbs PartialRbi].each do |name|
      Schematrix::Generators.const_get(name).new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe: ProjectMaybe,
      )
    end
  end

  def test_optionals_rejects_unknown_modes
    assert_raises(ArgumentError) do
      Schematrix::Generators::PlainRuby.new("/tmp", "Gen", optionals: :bang)
    end
  end

  def test_dsl_generators_reject_the_maybe_option
    assert_raises(ArgumentError) do
      Schematrix::Generators::DslPlainRuby.new("/tmp", "Gen", optionals: :maybe)
    end
  end

  def test_dsl_generators_reject_the_maybe_option_even_with_a_supplied_maybe
    assert_raises(ArgumentError) do
      Schematrix::Generators::DslPlainRuby.new(
        "/tmp",
        "Gen",
        optionals: :maybe,
        maybe: ProjectMaybe,
      )
    end
  end

  def test_one_generated_maybe_file_cannot_serve_two_modules
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "person.json")
      File.write(schema, MAYBE_MODULE_SCHEMA)

      output = File.join(dir, "out")
      error =
        assert_raises(Schematrix::OutputCollisionError) do
          Schematrix.generate(
            generators: [
              Schematrix::Generators::PlainRuby.new(
                output,
                "Gen",
                optionals: :maybe,
              ),
              Schematrix::Generators::PartialPlainRuby.new(output, "Other"),
            ],
            input_files: [schema],
          )
        end

      assert_includes error.message, "maybe.rb"
    end
  end

  def test_partial_generators_refuse_immutable
    assert_raises(ArgumentError) do
      Schematrix::Generators::PartialPlainRuby.new(
        "/tmp",
        "Gen",
        immutable: true,
      )
    end
  end

  def test_supplied_maybe_renders_through_the_project_type
    supplied =
      Schematrix::Generators::PlainRuby.new(
        "/tmp",
        "M",
        optionals: :maybe,
        maybe: ProjectMaybe,
      )
    uri =
      URI("file://#{File.expand_path("fixtures/maybe/schema.json", __dir__)}#/")
    node =
      Schematrix::Compiler
        .new(store: Schematrix::DocumentStore.new)
        .compile([File.join(FIXTURES_DIR, "maybe", "schema.json")])
        .fetch(uri.to_s)
    actual = supplied.transform(uri, "Schema", node)

    assert_includes actual, "::ProjectMaybe.from(hash[\"age\"])"
    assert_includes actual, "::ProjectMaybe.empty"
    assert_includes actual, ".when_present { |value| result["
    refute_includes actual, "T.absurd"
    refute_includes actual, "M::Maybe"
  end

  def test_a_generated_maybe_dumps_through_the_sealed_case
    actual = generate_fixture("maybe", "sorbet_ruby", optionals: :maybe)

    assert_includes actual, "when M::Maybe::Present"
    assert_includes actual, "T.absurd(@age)"
    assert_includes actual, "Maybe.from(\"none\")"
  end

  RUNTIME_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": {
        "firstName": { "type": "string" },
        "age": { "type": "integer", "default": 42 },
        "address": {
          "type": "object",
          "properties": { "street": { "type": "string" } }
        }
      },
      "required": ["firstName"]
    }
  JSON

  def test_generated_classes_keep_absent_and_null_apart
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "person.json")
      File.write(schema, RUNTIME_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(
            output,
            "Mb",
            optionals: :maybe,
          ),
          Schematrix::Generators::PartialPlainRuby.new(output, "Mb"),
          Schematrix::Generators::AuxiliaryFiles.new(output, "Mb"),
        ],
        input_files: [schema],
      )

      Dir["#{output}/**/*.rb"].each { |path| require(path) }
      maybe = Mb::Maybe

      cleared = Mb::Person.from_h("firstName" => "Ada", "age" => nil)
      assert_equal maybe.from(nil), cleared.age
      assert_equal({ "firstName" => "Ada", "age" => nil }, cleared.to_h)

      untouched = Mb::Person.from_h("firstName" => "Ada")
      assert_equal maybe.empty, untouched.address
      assert_equal({ "firstName" => "Ada", "age" => 42 }, untouched.to_h)

      defaulted = Mb::Person.from_h("firstName" => "Ada")
      assert_equal maybe.from(42), defaulted.age
      assert_equal({ "firstName" => "Ada", "age" => 42 }, defaulted.to_h)

      loaded =
        Mb::Person.from_h(
          "firstName" => "Ada",
          "address" => {
            "street" => "Main",
          },
        )
      assert_equal "Main", loaded.address.value.street.value
      assert_equal(
        {
          "firstName" => "Ada",
          "age" => 42,
          "address" => {
            "street" => "Main",
          },
        },
        loaded.to_h,
      )

      partial = Mb::Partial::Person.from_h("firstName" => "Ada", "age" => nil)
      assert_equal maybe.from("Ada"), partial.first_name
      assert_equal maybe.from(nil), partial.age
      assert_equal maybe.empty, partial.address
      assert_equal({ "firstName" => "Ada", "age" => nil }, partial.to_h)
      assert_equal({}, Mb::Partial::Person.from_h({}).to_h)

      assert_equal 36, maybe.from(36).value
      assert_equal 36, maybe.from(36).or_default(0)
      assert_equal 0, maybe.empty.or_default(0)
      assert_equal 5, maybe.from(4).map { |v| v + 1 }.value
      assert_equal(maybe.empty, maybe.empty.map { |v| v + 1 })
      seen = []
      maybe.from(4).when_present { |v| seen << v }
      assert_equal [4], seen
      seen << :touched
      maybe.empty.when_present { |v| seen << v }
      assert_equal [4, :touched], seen

      case partial.address
      when maybe::Present
        flunk("absent key is not present")
      when maybe::Absent
        nil
      else
        flunk("unreachable")
      end
    end
  end

  def test_maybe_and_auxiliary_targets_never_collide
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "person.json")
      File.write(schema, MAYBE_MODULE_SCHEMA)

      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(
            output,
            "Gen",
            optionals: :maybe,
          ),
          Schematrix::Generators::AuxiliaryFiles.new(output, "Gen"),
        ],
        input_files: [schema],
      )

      assert(File.exist?(File.join(output, "maybe.rb")))
      assert(File.exist?(File.join(output, "coercion_helper.rb")))
    end
  end
end
