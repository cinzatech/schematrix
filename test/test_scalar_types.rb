require_relative "test_helper"
require "tmpdir"

class TestScalarTypes < Minitest::Test
  include SchematrixTestHelper

  def test_builtin_table_renders_standard_formats
    date_time = Schematrix::BUILTIN_SCALAR_TYPES[%w[string date-time]]
    assert_equal "Time", date_time.sorbet
    assert_equal "Time", date_time.rbs
    date = Schematrix::BUILTIN_SCALAR_TYPES[%w[string date]]
    assert_equal "Date", date.sorbet
    assert_equal "Date", date.rbs
    assert_equal(Schematrix::Coercers::DateTime, date_time.coercer)
    assert_nil Schematrix::BUILTIN_SCALAR_TYPES[["string", nil]].coercer
  end

  def test_scalar_type_knows_when_it_coerces
    assert Schematrix::BUILTIN_SCALAR_TYPES[%w[string date]].coerces?
    refute Schematrix::BUILTIN_SCALAR_TYPES[["string", nil]].coerces?
    refute(Schematrix::ScalarType.new(sorbet: "Money", rbs: "Money").coerces?)
  end

  def test_visitor_copies_format_into_the_compiled_record
    schema = File.join(FIXTURES_DIR, "formatted_scalars", "schema.json")
    objects = compile_fixture("formatted_scalars")
    root = objects.fetch("file://#{File.expand_path(schema)}#/")

    assert_equal "date-time", root.properties["created_at"].format
    assert_equal "date", root.properties["birthday"].format
    assert_equal "email", root.properties["email"].format
    assert_nil root.properties["count"].format
  end

  def test_generated_output_loads_without_the_gem_and_round_trips
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "event.json")
      File.write(schema, <<~JSON)
        {
          "title": "Event",
          "type": "object",
          "properties": {
            "starts_at": { "type": "string", "format": "date-time" },
            "day": { "type": "string", "format": "date" }
          },
          "required": ["starts_at"]
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Events"),
          Schematrix::Generators::CoercionHelper.new(output, "Events"),
        ],
        input_files: [schema],
      )

      script = File.join(dir, "check.rb")
      File.write(script, <<~RUBY)
        load #{File.join(output, "event.rb").inspect}
        event = Events::Event.from_h(
          "starts_at" => "2026-10-22T22:54:11Z",
          "day" => "2026-10-22"
        )
        raise unless event.starts_at.is_a?(Time)
        raise unless event.day.is_a?(Date)
        dumped = event.to_h
        raise unless dumped["starts_at"] == "2026-10-22T22:54:11Z"
        raise unless dumped["day"] == "2026-10-22"
        puts "ok"
      RUBY

      # A clean interpreter, no load path, no bundler: the generated
      # file must run on stdlib alone.
      out = IO.popen([RbConfig.ruby, script], &:read)
      assert_equal "ok\n", out
    end
  end

  def test_generated_coercers_behave_like_the_gem_modules
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "stamp.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": {
            "at": { "type": "string", "format": "date-time" },
            "day": { "type": "string", "format": "date" }
          }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Stamps"),
          Schematrix::Generators::CoercionHelper.new(output, "Stamps"),
        ],
        input_files: [schema],
      )
      load File.join(output, "stamp.rb")

      pairs = {
        ["at", Schematrix::Coercers::DateTime] => [
          "2026-10-22T22:54:11Z",
          Time.utc(2026, 10, 22, 22, 54, 11),
          42,
          43,
        ],
        ["day", Schematrix::Coercers::Date] => [
          "2026-10-22",
          Date.new(2026, 10, 22),
          7,
          8,
        ],
      }
      pairs.each do |(property, coercer), (document, instance, one, two)|
        generated = Stamps::Stamp.method("coerce_#{property}")
        assert_equal coercer.coerce(document), generated.call(document)
        assert_equal coercer.coerce(instance), generated.call(instance)
        assert_equal coercer.coerce(one), generated.call(one)
        assert_equal coercer.coerce(two), generated.call(two)
      end
    end
  end

  def test_project_scalar_types_render_and_delegate_by_name
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "invoice.json")
      File.write(schema, <<~JSON)
        {
          "title": "Invoice",
          "type": "object",
          "properties": {
            "id": { "type": "integer", "format": "id" },
            "created_at": { "type": "string", "format": "date-time" },
            "amount": { "type": "string", "format": "money" }
          },
          "required": ["id", "created_at", "amount"]
        }
      JSON
      output = File.join(dir, "out")
      generator =
        Schematrix::Generators::SorbetRuby.new(
          output,
          "Billing",
          scalar_types: {
            %w[string money] =>
              Schematrix::ScalarType.new(
                sorbet: "Money",
                rbs: "Money",
                coercer: MoneyCoercer,
              ),
            %w[integer id] =>
              Schematrix::ScalarType.new(sorbet: "Id", rbs: "Id"),
          },
        )
      objects =
        Schematrix::Compiler.new(store: Schematrix::DocumentStore.new).compile(
          [schema],
        )
      locator, node = objects.first
      code = generator.transform(URI(locator), "Invoice", node)

      assert_includes code,
                      "params(id: Id, created_at: Time, amount: Money).void"
      assert_includes code, "MoneyCoercer.coerce(value)"
      assert_includes code,
                      "Billing::Schematrix::Coercers::DateTime.coerce(value)"
      refute_includes code, "def self.coerce_id"
      assert_includes code,
                      "created_at: coerce_created_at(hash[\"created_at\"])"
      assert_includes code, "id: hash[\"id\"]"
      # The project coercer is referenced by name, never emitted; the
      # built-in one still is.
      refute_includes code, "module MoneyCoercer"
      assert_includes code, "module DateTime"
    end
  end

  def test_project_table_overrides_a_builtin_entry
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "plain.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": {
            "at": { "type": "string", "format": "date-time" }
          }
        }
      JSON
      output = File.join(dir, "out")
      generator =
        Schematrix::Generators::PlainRuby.new(
          output,
          "M",
          scalar_types: {
            %w[string date-time] =>
              Schematrix::ScalarType.new(
                sorbet: "MyTime",
                rbs: "my_time",
                coercer: MoneyCoercer,
              ),
          },
        )
      objects =
        Schematrix::Compiler.new(store: Schematrix::DocumentStore.new).compile(
          [schema],
        )
      locator, node = objects.first
      code = generator.transform(URI(locator), "Plain", node)

      assert_includes code, "MoneyCoercer.coerce(value)"
      refute_includes code, "module DateTime"
      refute_includes code, "Coercers"
    end
  end

  def test_anonymous_coercer_fails_at_construction
    error =
      assert_raises(ArgumentError) do
        Schematrix::Generators::PlainRuby.new(
          "/tmp/schematrix-nonexistent",
          "M",
          scalar_types: {
            %w[string money] =>
              Schematrix::ScalarType.new(
                sorbet: "Money",
                rbs: "Money",
                coercer: Module.new,
              ),
          },
        )
      end

    assert_includes error.message, "must be a named module answering"
  end

  def test_coercer_without_coerce_method_fails_at_construction
    error =
      assert_raises(ArgumentError) do
        Schematrix::Generators::PlainRuby.new(
          "/tmp/schematrix-nonexistent",
          "M",
          scalar_types: {
            %w[string money] =>
              Schematrix::ScalarType.new(
                sorbet: "Money",
                rbs: "Money",
                coercer: Kernel,
              ),
          },
        )
      end

    assert_includes error.message, "Kernel"
  end

  def test_non_module_coercer_fails_at_construction
    error =
      assert_raises(ArgumentError) do
        Schematrix::Generators::PlainRuby.new(
          "/tmp/schematrix-nonexistent",
          "M",
          scalar_types: {
            %w[string money] =>
              Schematrix::ScalarType.new(
                sorbet: "Money",
                rbs: "Money",
                coercer: "Money",
              ),
          },
        )
      end

    assert_includes error.message, %("Money")
  end

  def test_no_output_is_written_when_a_coercer_is_invalid
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "order.json")
      File.write(schema, SIMPLE_SCHEMA)

      assert_raises(ArgumentError) do
        Schematrix.generate(
          generators: [
            Schematrix::Generators::PlainRuby.new(
              File.join(dir, "out"),
              "M",
              scalar_types: {
                %w[string money] =>
                  Schematrix::ScalarType.new(
                    sorbet: "Money",
                    rbs: "Money",
                    coercer: Module.new,
                  ),
              },
            ),
          ],
          input_files: [schema],
        )
      end

      assert_empty Dir.glob("#{dir}/out/**/*")
    end
  end

  def test_nested_format_slots_convert_and_round_trip
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "nested.json")
      File.write(schema, <<~JSON)
        {
          "title": "Nested",
          "type": "object",
          "properties": {
            "log": {
              "type": "array",
              "items": { "type": "string", "format": "date-time" }
            },
            "window": {
              "type": "array",
              "prefixItems": [
                { "type": "string", "format": "date" },
                { "type": "string", "format": "date-time" }
              ],
              "items": false
            },
            "rates": {
              "type": "object",
              "additionalProperties": {
                "type": "string", "format": "date-time"
              }
            },
            "milestone": {
              "anyOf": [
                { "type": "string", "format": "date" },
                { "type": "integer" }
              ]
            }
          },
          "additionalProperties": { "type": "string", "format": "date" }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Nested"),
          Schematrix::Generators::CoercionHelper.new(output, "Nested"),
        ],
        input_files: [schema],
      )
      load File.join(output, "nested.rb")

      document = {
        "log" => %w[2026-01-01T10:00:00Z 2026-01-02T11:30:00+01:00],
        "window" => %w[2026-01-01 2026-01-01T10:00:00Z],
        "rates" => {
          "eu" => "2026-01-01T00:00:00Z",
        },
        "milestone" => "2026-05-06",
        "rider" => "2026-03-03",
      }
      nested = Nested::Nested.from_h(document)
      assert_equal(
        [
          Time.utc(2026, 1, 1, 10, 0, 0),
          Time.new(2026, 1, 2, 11, 30, 0, "+01:00"),
        ],
        nested.log,
      )
      assert_equal(
        [Date.new(2026, 1, 1), Time.utc(2026, 1, 1, 10, 0, 0)],
        nested.window,
      )
      assert_equal({ "eu" => Time.utc(2026, 1, 1) }, nested.rates)
      assert_equal(Date.new(2026, 5, 6), nested.milestone)
      assert_equal(Date.new(2026, 3, 3), nested["rider"])
      assert_equal(document, nested.to_h)
    end
  end

  def test_union_of_coercing_scalar_and_class_converts_both_branches
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "union.json")
      File.write(schema, <<~JSON)
        {
          "title": "Union",
          "type": "object",
          "properties": {
            "amount": {
              "anyOf": [
                { "type": "string", "format": "date-time" },
                { "$ref": "#/$defs/money" }
              ]
            }
          },
          "$defs": {
            "money": {
              "type": "object",
              "properties": { "cents": { "type": "integer" } },
              "required": ["cents"]
            }
          }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Unions"),
          Schematrix::Generators::CoercionHelper.new(output, "Unions"),
        ],
        input_files: [schema],
      )
      load File.join(output, "union/defs/money.rb")
      load File.join(output, "union.rb")

      stamped = Unions::Union.from_h("amount" => "2026-01-01T10:00:00Z")
      assert_equal(Time.utc(2026, 1, 1, 10, 0, 0), stamped.amount)
      money = Unions::Union.from_h("amount" => { "cents" => 42 })
      assert_instance_of Unions::Union::Defs::Money, money.amount
      assert_equal({ "amount" => { "cents" => 42 } }, money.to_h)
    end
  end

  def test_mixed_coercers_in_one_union_raise
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "conflict.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": {
            "when": {
              "anyOf": [
                { "type": "string", "format": "date" },
                { "type": "string", "format": "date-time" }
              ]
            }
          }
        }
      JSON
      output = File.join(dir, "out")

      error =
        assert_raises(Schematrix::CoercionConflictError) do
          Schematrix.generate(
            generators: [Schematrix::Generators::PlainRuby.new(output, "M")],
            input_files: [schema],
          )
        end

      assert_includes error.message, "would both convert String"
    end
  end

  def test_formatted_catch_all_converts_without_property_specs
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "rider.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": { "count": { "type": "integer" } },
          "additionalProperties": { "type": "string", "format": "date-time" }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Riders"),
          Schematrix::Generators::CoercionHelper.new(output, "Riders"),
        ],
        input_files: [schema],
      )
      load File.join(output, "rider.rb")

      rider =
        Riders::Rider.from_h({ "count" => 1, "at" => "2026-01-01T10:00:00Z" })
      assert_equal Time.utc(2026, 1, 1, 10, 0, 0), rider["at"]
      assert_equal({ "count" => 1, "at" => "2026-01-01T10:00:00Z" }, rider.to_h)
    end
  end

  def test_rbi_declares_the_spec_helpers_a_catch_all_only_class_needs
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "rider.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": { "count": { "type": "integer" } },
          "additionalProperties": {
            "anyOf": [
              { "type": "string", "format": "date-time" },
              { "$ref": "#/$defs/money" }
            ]
          },
          "$defs": {
            "money": {
              "type": "object",
              "properties": { "cents": { "type": "integer" } },
              "required": ["cents"]
            }
          }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [Schematrix::Generators::Rbi.new(output, "Riders")],
        input_files: [schema],
      )
      code = File.read(File.join(output, "rider.rbi"))

      assert_includes code, "def self.coerce_extra(value)"
      refute_includes code, "def self.coerce_class_slot(value, klass)"
      refute_includes code, "def self.coerce_spec(value, spec)"
    end
  end

  def test_union_branch_that_is_itself_a_union_converts
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "nested_union.json")
      File.write(schema, <<~JSON)
        {
          "title": "NestedUnion",
          "type": "object",
          "properties": {
            "weird": {
              "anyOf": [
                {
                  "type": "array",
                  "items": { "type": "string", "format": "date" }
                },
                {
                  "anyOf": [
                    { "type": "string", "format": "date-time" },
                    { "$ref": "#/$defs/money" }
                  ]
                }
              ]
            }
          },
          "$defs": {
            "money": {
              "type": "object",
              "properties": { "cents": { "type": "integer" } },
              "required": ["cents"]
            }
          }
        }
      JSON
      output = File.join(dir, "out")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Nesteds"),
          Schematrix::Generators::CoercionHelper.new(output, "Nesteds"),
        ],
        input_files: [schema],
      )
      load File.join(output, "nested_union/defs/money.rb")
      load File.join(output, "nested_union.rb")

      days = Nesteds::NestedUnion.from_h({ "weird" => ["2026-01-01"] })
      assert_equal([Date.new(2026, 1, 1)], days.weird)
      stamped =
        Nesteds::NestedUnion.from_h({ "weird" => "2026-01-01T10:00:00Z" })
      assert_equal(Time.utc(2026, 1, 1, 10, 0, 0), stamped.weird)
      money = Nesteds::NestedUnion.from_h({ "weird" => { "cents" => 7 } })
      assert_instance_of Nesteds::NestedUnion::Defs::Money, money.weird
      assert_equal({ "weird" => { "cents" => 7 } }, money.to_h)
    end
  end

  def test_nested_unions_with_conflicting_coercers_raise
    Dir.mktmpdir do |dir|
      schema = File.join(dir, "conflict.json")
      File.write(schema, <<~JSON)
        {
          "type": "object",
          "properties": {
            "when": {
              "anyOf": [
                {
                  "anyOf": [
                    { "type": "string", "format": "date" },
                    { "$ref": "#/$defs/one" }
                  ]
                },
                {
                  "anyOf": [
                    { "type": "string", "format": "date-time" },
                    { "$ref": "#/$defs/two" }
                  ]
                }
              ]
            }
          },
          "$defs": {
            "one": {
              "type": "object",
              "properties": { "a": { "type": "integer" } },
              "required": ["a"]
            },
            "two": {
              "type": "object",
              "properties": { "b": { "type": "integer" } },
              "required": ["b"]
            }
          }
        }
      JSON
      output = File.join(dir, "out")

      error =
        assert_raises(Schematrix::CoercionConflictError) do
          Schematrix.generate(
            generators: [Schematrix::Generators::PlainRuby.new(output, "M")],
            input_files: [schema],
          )
        end

      assert_includes error.message, "would both convert String"
    end
  end

  SIMPLE_SCHEMA = <<~JSON
    {
      "type": "object",
      "properties": { "id": { "type": "string" } }
    }
  JSON
end

module MoneyCoercer
  def self.coerce(value) = value
end
