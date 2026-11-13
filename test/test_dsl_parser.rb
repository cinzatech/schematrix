require_relative "test_helper"
require "tmpdir"
require "open3"

class TestDslParser < Minitest::Test
  module Reader
    def self.read(node)
      raise ArgumentError, "reader failed" if node.location.slice == "broken()"

      "read:#{node.location.slice}"
    end
  end

  module Coercer
    def self.coerce(value)
      "coerced:#{value}"
    end
  end

  module MissingReader
  end

  Color =
    Data.define(:hex) do
      def self.coerce(value)
        value.is_a?(self) ? value.hex : value
      end
    end

  RED = Color.new("#ff0000")

  module ColorReader
    def self.read(node)
      unless node.is_a?(Prism::ConstantPathNode)
        raise ArgumentError, "expected a constant path"
      end

      if node.full_name.delete_prefix("::") != "TestDslParser::RED"
        raise ArgumentError, "expected TestDslParser::RED"
      end

      "#ff0000"
    end
  end

  module DateReader
    def self.read(node)
      unless node.is_a?(Prism::CallNode) && node.name == :new
        raise ArgumentError, "expected Date.new"
      end

      receiver = node.receiver
      unless receiver.is_a?(Prism::ConstantReadNode) && receiver.name == :Date
        raise ArgumentError, "expected Date.new"
      end

      raise ArgumentError, "unexpected block" if node.block

      arguments = node.arguments&.arguments || []
      unless arguments.size == 3 && arguments.all?(Prism::IntegerNode)
        raise ArgumentError, "expected three integers"
      end

      Date.new(*arguments.map(&:value)).iso8601
    end
  end

  def test_reader_values_equal_runtime_serialization_in_every_container
    color = { type: "string", format: "color" }
    schema = {
      type: "object",
      properties: {
        color: color,
        colors: {
          type: "array",
          items: color,
        },
        tuple: {
          type: "array",
          prefixItems: [{ type: "integer" }, color],
        },
        palette: {
          type: "object",
          additionalProperties: color,
        },
        palettes: {
          type: "array",
          items: {
            type: "object",
            additionalProperties: color,
          },
        },
      },
      additionalProperties: color,
    }
    types = {
      %w[string color] =>
        Schematrix::ScalarType.new(
          sorbet: "TestDslParser::Color",
          rbs: "TestDslParser::Color",
          coercer: Color,
          reader: ColorReader,
        ),
    }
    with_generated(
      schema,
      builders: true,
      scalar_types: types,
    ) do |parser, namespace, _output|
      source = <<~RUBY
        #{namespace}::Dsl::Schema.build do
          color TestDslParser::RED
          colors TestDslParser::RED
          tuple 1
          tuple TestDslParser::RED
          palette "red", TestDslParser::RED
          palettes({"red" => TestDslParser::RED})
          extra "favorite", TestDslParser::RED
        end
      RUBY
      expected = eval(source) # rubocop:disable Security/Eval
      assert_equal "#ff0000", expected.fetch("color")
      assert_equal expected, parser.parse(source)
    end
  end

  def test_builtin_date_reader_returns_document_value_without_second_coercion
    types = {
      %w[string date] =>
        Schematrix::ScalarType.new(
          sorbet: "Date",
          rbs: "Date",
          coercer: Schematrix::Coercers::Date,
          reader: DateReader,
        ),
    }
    with_generated(
      object_schema(format: "date"),
      builders: true,
      scalar_types: types,
    ) do |parser, namespace, _output|
      source =
        "#{namespace}::Dsl::Schema.build do; value Date.new(2026, 1, 2); end"
      assert_equal({ "value" => "2026-01-02" }, parser.parse(source))
      assert_equal eval(source), parser.parse(source) # rubocop:disable Security/Eval
    end
  end

  def test_ambiguous_readers_fail_generation
    schema = {
      type: "object",
      properties: {
        value: {
          anyOf: [
            { type: "string", format: "color" },
            { type: "integer", format: "id" },
          ],
        },
      },
    }
    types = {
      %w[string color] =>
        Schematrix::ScalarType.new(
          sorbet: "String",
          rbs: "String",
          reader: ColorReader,
        ),
      %w[integer id] =>
        Schematrix::ScalarType.new(
          sorbet: "Integer",
          rbs: "Integer",
          reader: Reader,
        ),
    }
    assert_raises(Schematrix::CoercionConflictError) do
      with_generated(schema, scalar_types: types) do
        flunk "ambiguous reader accepted"
      end
    end
  end

  def test_registry
    assert_equal Schematrix::Generators::DslParser,
                 Schematrix::GENERATORS.fetch("dsl_parser")
  end

  def test_generated_parser_matches_real_builder_for_repeated_and_nested_setters
    person = {
      type: "object",
      properties: {
        name: {
          type: "string",
        },
        age: {
          type: "integer",
        },
      },
    }
    schema = {
      type: "object",
      properties: {
        name: {
          type: "string",
        },
        person: person,
        tags: {
          type: "array",
          items: {
            type: "string",
          },
        },
        people: {
          type: "array",
          items: person,
        },
        labels: {
          type: "object",
          additionalProperties: {
            type: "integer",
          },
        },
        contacts: {
          type: "object",
          additionalProperties: person,
        },
        mixed: {
          type: "array",
          items: {
            anyOf: [{ type: "string" }, person],
          },
        },
        option: {
          type: %w[string object],
          properties: {
            name: {
              type: "string",
            },
          },
        },
        matrix: {
          type: "array",
          items: {
            type: "array",
            items: {
              type: "integer",
            },
          },
        },
      },
    }
    with_generated(schema, builders: true) do |parser, namespace, _output|
      source = <<~RUBY
        #{namespace}::Dsl::Schema.build do
          name "first"
          name "last"
          person do
            name "Ada"
          end
          person do
            age 36
          end
          tags "a", "b"
          tags "c"
          people do
            name "Grace"
          end
          people do
            name "Alan"
          end
          labels "count", 1
          labels "count", 2
          contacts "mentor" do
            name "Charles"
          end
          mixed "plain"
          mixed do
            name "nested"
          end
          option "plain"
          option do
            name "object"
          end
          matrix [1, 2], [3]
          extra "nickname", "A"
          extra "config", {"retry" => true}
        end
      RUBY
      expected = eval(source) # rubocop:disable Security/Eval
      assert_equal expected, parser.parse(source)
      assert_equal "last", expected.fetch("name")
      assert_equal({ "name" => "Ada", "age" => 36 }, expected.fetch("person"))
      assert_equal %w[a b c], expected.fetch("tags")
    end
  end

  def test_generated_parser_matches_real_builder_for_blockless_object_setters
    shape = { type: "object", properties: { name: { type: "string" } } }
    schema = {
      type: "object",
      properties: {
        person: shape,
        people: {
          type: "array",
          items: shape,
        },
        contacts: {
          type: "object",
          additionalProperties: shape,
        },
      },
    }
    with_generated(schema, builders: true) do |parser, namespace, _output|
      source = <<~RUBY
        #{namespace}::Dsl::Schema.build do
          person
          people
          people do
            name "Ada"
          end
          contacts "mentor"
          contacts "peer" do
            name "Grace"
          end
        end
      RUBY
      expected = eval(source) # rubocop:disable Security/Eval
      assert_equal expected, parser.parse(source)
      assert_equal(
        {
          "person" => {},
          "people" => [{}, { "name" => "Ada" }],
          "contacts" => { "mentor" => {}, "peer" => { "name" => "Grace" } },
        },
        expected,
      )
    end
  end

  def test_wrappers_and_instance_methods_do_not_create_constants
    with_generated(object_schema) do |parser, namespace, output|
      source = <<~RUBY
        module UncreatedOuter
          module UncreatedInner
            class UncreatedDocument
              extend #{namespace}::Dsl::Schema
              value "hello"
            end
          end
        end
      RUBY
      path = File.join(output, "document.rb")
      File.write(path, source)
      expected = { "value" => "hello" }
      assert_equal expected, parser.parse(source)
      assert_equal expected, parser.parse_file(path)
      instance = Class.new { include parser }.new
      assert_equal expected, instance.parse(source)
      assert_equal expected, instance.parse_file(path)
      refute Object.const_defined?(:UncreatedOuter, false)
    end
  end

  def test_parser_does_not_apply_defaults_or_validate_required_properties
    schema = object_schema.merge(required: ["value"])
    schema[:properties][:value][:default] = "default"
    with_generated(schema) do |parser, namespace, _output|
      assert_equal({}, parser.parse("#{namespace}::Dsl::Schema.build do; end"))
      assert_equal(
        { "value" => 42 },
        parser.parse("#{namespace}::Dsl::Schema.build do; value 42; end"),
      )
    end
  end

  def test_generated_parser_runs_without_generator_builder_or_enum_code
    schema = {
      type: "object",
      properties: {
        status: {
          type: "string",
          enum: %w[ready done],
        },
      },
    }
    with_generated(schema, enums: :classes) do |_parser, namespace, output|
      source =
        "#{namespace}::Dsl::Schema.build do; " \
          "status #{namespace}::Schema::Props::Status::Ready; end"
      script = <<~RUBY
        require #{File.join(output, "parser/schema.rb").inspect}
        require "json"
        raise "schematrix loaded" if defined?(Schematrix)
        raise "builder loaded" if defined?(#{namespace}::Dsl)
        raise "enum loaded" if defined?(#{namespace}::Schema)
        puts JSON.generate(#{namespace}::Parser::Schema.parse(#{source.inspect}))
      RUBY
      stdout, stderr, status =
        Open3.capture3(
          { "RUBYOPT" => nil },
          RbConfig.ruby,
          "--disable-gems",
          "-I",
          Gem
            .loaded_specs
            .fetch("prism")
            .full_require_paths
            .join(File::PATH_SEPARATOR),
          "-I",
          Gem
            .loaded_specs
            .fetch("json")
            .full_require_paths
            .join(File::PATH_SEPARATOR),
          "-e",
          script,
        )
      assert status.success?, stderr
      assert_equal({ "status" => "ready" }, JSON.parse(stdout))
    end
  end

  def test_reader_covers_scalar_array_tuple_map_extra_and_nested_array
    scalar = { type: "string", format: "custom" }
    schema = {
      type: "object",
      properties: {
        value: scalar,
        values: {
          type: "array",
          items: scalar,
        },
        tuple: {
          type: "array",
          prefixItems: [{ type: "integer" }, scalar],
          items: scalar,
        },
        lookup: {
          type: "object",
          additionalProperties: scalar,
        },
        nested: {
          type: "array",
          items: {
            type: "array",
            items: scalar,
          },
        },
      },
      additionalProperties: scalar,
    }
    with_generated(
      schema,
      scalar_types: custom_types,
    ) do |parser, namespace, _output|
      source = <<~RUBY
        #{namespace}::Dsl::Schema.build do
          value token()
          values first(), second()
          tuple 7
          tuple third()
          tuple fourth()
          lookup "key", fifth()
          nested [sixth(), "literal"]
          extra "other", seventh()
        end
      RUBY
      assert_equal(
        {
          "value" => "read:token()",
          "values" => %w[read:first() read:second()],
          "tuple" => [7, "read:third()", "read:fourth()"],
          "lookup" => {
            "key" => "read:fifth()",
          },
          "nested" => [%w[read:sixth() literal]],
          "other" => "read:seventh()",
        },
        parser.parse(source),
      )
    end
  end

  def test_json_literals_pass_through_custom_coercers_in_both_paths
    with_generated(
      object_schema(format: "custom"),
      builders: true,
      scalar_types: custom_types,
    ) do |parser, namespace, _output|
      source = "#{namespace}::Dsl::Schema.build do; value 'literal'; end"
      expected = { "value" => "literal" }
      assert_equal expected, parser.parse(source)
      assert_equal expected, eval(source) # rubocop:disable Security/Eval
      builder = Object.const_get(namespace)::Dsl::Schema
      assert_equal(
        { "value" => "coerced:#{Color.new("raw")}" },
        builder.build { value Color.new("raw") },
      )
    end
  end

  def test_tuple_offset_matches_builder_across_repeated_calls
    scalar = { type: "string", format: "custom" }
    schema = {
      type: "object",
      properties: {
        values: {
          type: "array",
          prefixItems: [{ type: "integer" }, scalar],
          items: {
            type: "string",
          },
        },
      },
    }
    with_generated(
      schema,
      builders: true,
      scalar_types: custom_types,
    ) do |parser, namespace, _output|
      source = <<~RUBY
        #{namespace}::Dsl::Schema.build do
          values 1
          values "second"
          values "third", "fourth"
        end
      RUBY
      expected = { "values" => [1, "second", "third", "fourth"] }
      assert_equal expected, parser.parse(source)
      assert_equal expected, eval(source) # rubocop:disable Security/Eval
    end
  end

  def test_builtin_date_and_time_literals_remain_unchanged
    schema = {
      type: "object",
      properties: {
        day: {
          type: "string",
          format: "date",
        },
        at: {
          type: "string",
          format: "date-time",
        },
      },
    }
    with_generated(schema, builders: true) do |parser, namespace, _output|
      source =
        "#{namespace}::Dsl::Schema.build do; day 'not a date'; " \
          "at '2026-01-01T01:02:03+02:00'; end"
      expected = { "day" => "not a date", "at" => "2026-01-01T01:02:03+02:00" }
      assert_equal expected, parser.parse(source)
      assert_equal expected, eval(source) # rubocop:disable Security/Eval
      builder = Object.const_get(namespace)::Dsl::Schema
      assert_equal(
        { "day" => "2026-01-02", "at" => "2026-01-02T03:04:05Z" },
        builder.build do
          day Date.new(2026, 1, 2)
          at Time.utc(2026, 1, 2, 3, 4, 5)
        end,
      )
    end
  end

  def test_reader_failure_has_source_location_and_preserves_cause
    with_generated(
      object_schema(format: "custom"),
      scalar_types: custom_types,
    ) do |parser, namespace, _output|
      error =
        assert_raises(Object.const_get(namespace)::Parser::ParseError) do
          parser.parse(
            "#{namespace}::Dsl::Schema.build do\n  value broken()\nend",
            filename: "input.dsl",
          )
        end
      assert_equal "input.dsl", error.filename
      assert_equal 2, error.line
      assert_operator error.column, :>=, 1
      assert_equal "value", error.keyword.to_s
      refute_empty error.reason
      assert_instance_of ArgumentError, error.cause
      assert_equal "reader failed", error.cause.message
    end
  end

  def test_nonliteral_values_without_reader_are_rejected
    with_generated(object_schema) do |parser, namespace, _output|
      assert_raises(Object.const_get(namespace)::Parser::ParseError) do
        parser.parse("#{namespace}::Dsl::Schema.build do; value token(); end")
      end
    end
  end

  def test_invalid_readers_are_rejected_at_generator_construction
    [
      Module.new do
        def self.read(node)
          node.location.slice
        end
      end,
      MissingReader,
    ].each do |reader|
      entry =
        Schematrix::ScalarType.new(
          sorbet: "String",
          rbs: "String",
          reader: reader,
        )
      Dir.mktmpdir do |output|
        assert_raises(ArgumentError) do
          Schematrix::Generators::DslParser.new(
            output,
            "ReaderValidation",
            scalar_types: {
              %w[string custom] => entry,
            },
          )
        end
        assert_empty Dir.children(output)
      end
    end
  end

  def test_reserved_output_names_fail_before_writing
    %w[runtime parse_error].each do |name|
      Dir.mktmpdir do |dir|
        input = File.join(dir, "#{name}.json")
        File.write(input, JSON.generate(object_schema))
        output = File.join(dir, "output")
        generator =
          Schematrix::Generators::DslParser.new(output, "CollisionCheck")
        assert_raises(Schematrix::OutputCollisionError) do
          Schematrix.generate(generators: [generator], input_files: [input])
        end
        assert_empty Dir.glob(File.join(output, "**", "*"))
      end
    end
  end

  def test_unsupported_options_are_rejected
    Dir.mktmpdir do |output|
      [{ immutable: true }, { optionals: :maybe }].each do |options|
        assert_raises(ArgumentError) do
          Schematrix::Generators::DslParser.new(
            output,
            "OptionCheck",
            **options,
          )
        end
      end
    end
  end

  def test_builders_generate_alongside_conflicting_readers_without_a_parser
    schema = {
      type: "object",
      properties: {
        value: {
          anyOf: [
            { type: "string", format: "color" },
            { type: "integer", format: "id" },
          ],
        },
      },
    }
    types = {
      %w[string color] =>
        Schematrix::ScalarType.new(
          sorbet: "String",
          rbs: "String",
          reader: ColorReader,
        ),
      %w[integer id] =>
        Schematrix::ScalarType.new(
          sorbet: "Integer",
          rbs: "Integer",
          reader: Reader,
        ),
    }
    Dir.mktmpdir do |dir|
      input = File.join(dir, "schema.json")
      File.write(input, JSON.generate(schema))
      output = File.join(dir, "output")
      generator =
        Schematrix::Generators::DslPlainRuby.new(
          output,
          "NoParser",
          scalar_types: types,
        )
      Schematrix.generate(generators: [generator], input_files: [input])
      assert File.file?(File.join(output, "dsl/schema.rb"))
    end
  end

  def test_unremapped_date_slots_type_as_string_and_remaps_keep_their_spelling
    schema = {
      type: "object",
      properties: {
        day: {
          type: "string",
          format: "date",
        },
        stamp: {
          type: "string",
          format: "date-time",
        },
      },
    }
    remap =
      Schematrix::ScalarType.new(
        sorbet: "MyDate",
        rbs: "MyDate",
        coercer: Schematrix::Coercers::Date,
        reader: DateReader,
      )
    Dir.mktmpdir do |dir|
      input = File.join(dir, "schema.json")
      File.write(input, JSON.generate(schema))

      plain = File.join(dir, "plain")
      Schematrix.generate(
        generators: [Schematrix::Generators::DslSorbetRuby.new(plain, "Sigs")],
        input_files: [input],
      )
      code = File.read(File.join(plain, "dsl/schema.rb"))
      assert_includes code, "params(value: String)"
      refute_includes code, "params(value: Time)"
      refute_includes code, "params(value: Date)"

      remapped = File.join(dir, "remapped")
      types = { %w[string date] => remap, %w[string date-time] => remap }
      Schematrix.generate(
        generators: [
          Schematrix::Generators::DslSorbetRuby.new(
            remapped,
            "Sigs",
            scalar_types: types,
          ),
        ],
        input_files: [input],
      )
      code = File.read(File.join(remapped, "dsl/schema.rb"))
      assert_includes code, "params(value: MyDate)"
    end
  end

  def test_parsed_document_round_trips_through_a_data_class
    Dir.mktmpdir do |dir|
      input = File.join(dir, "schema.json")
      File.write(input, JSON.generate(object_schema))
      output = File.join(dir, "output")
      Schematrix.generate(
        generators: [
          Schematrix::Generators::PlainRuby.new(output, "Round"),
          Schematrix::Generators::DslPlainRuby.new(output, "Round"),
          Schematrix::Generators::DslParser.new(output, "Round"),
          Schematrix::Generators::AuxiliaryFiles.new(output, "Round"),
        ],
        input_files: [input],
      )
      Dir.glob("#{output}/**/*.rb").each { |file| require file }
      source = "Round::Dsl::Schema.build do; value '42'; end"
      document = Round::Parser::Schema.parse(source)
      record = Round::Schema.from_h(document)
      assert_equal document, record.to_h
    ensure
      Object.send(:remove_const, :Round) if Object.const_defined?(:Round)
    end
  end

  def test_extend_may_appear_anywhere_in_the_declaration_body
    with_generated(object_schema) do |parser, namespace, _output|
      first = <<~RUBY
        module Late
          value "hello"
          extend #{namespace}::Dsl::Schema
          value "world"
        end
      RUBY
      assert_equal({ "value" => "world" }, parser.parse(first))

      middle = <<~RUBY
        module Mid
          value "a"
          extend #{namespace}::Dsl::Schema
        end
      RUBY
      assert_equal({ "value" => "a" }, parser.parse(middle))
    end
  end

  def test_non_setter_rejections_omit_the_stale_keyword
    schema = {
      type: "object",
      properties: {
        other: {
          type: "integer",
        },
        value: {
          type: "string",
        },
      },
    }
    with_generated(schema) do |parser, namespace, _output|
      source = <<~RUBY
        module Strict
          extend #{namespace}::Dsl::Schema
          other 1
          value "x" if ENV["STRICT"]
        end
      RUBY
      error =
        assert_raises(Object.const_get(namespace)::Parser::ParseError) do
          parser.parse(source, filename: "expense.rb")
        end
      assert_nil error.keyword
      assert_equal 4, error.line
      assert_equal "expected a receiverless setter call", error.reason
    end
  end

  private

  def object_schema(**options)
    { type: "object", properties: { value: { type: "string", **options } } }
  end

  def custom_types
    {
      %w[string custom] =>
        Schematrix::ScalarType.new(
          sorbet: "String",
          rbs: "String",
          coercer: Coercer,
          reader: Reader,
        ),
    }
  end

  def with_generated(schema, builders: false, **)
    namespace = "ParserIntegration#{object_id}"
    Dir.mktmpdir do |dir|
      input = File.join(dir, "schema.json")
      File.write(input, JSON.generate(schema))
      output = File.join(dir, "output")
      generators = [
        Schematrix::Generators::DslParser.new(output, namespace, **),
      ]
      if builders
        generators << Schematrix::Generators::DslPlainRuby.new(
          output,
          namespace,
          **,
        )
      end
      Schematrix.generate(generators: generators, input_files: [input])
      assert File.file?(File.join(output, "parser/runtime.rb"))
      assert File.file?(File.join(output, "parser/parse_error.rb"))
      require File.join(output, "parser/schema.rb")
      if builders
        Dir.glob(File.join(output, "dsl/**/*.rb")).each { |file| require file }
      end
      yield Object.const_get(namespace)::Parser::Schema, namespace, output
    end
  ensure
    if namespace && Object.const_defined?(namespace, false)
      Object.send(:remove_const, namespace)
    end
  end
end
