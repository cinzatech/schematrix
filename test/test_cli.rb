require_relative "test_helper"
require_relative "../lib/schematrix/cli"
require "tmpdir"

class TestCLI < Minitest::Test
  def test_usage_line_advertises_no_subcommand
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M schema.json])

    assert_equal "Usage: schematrix [OPTIONS] INPUT [INPUT...]\n",
                 cli.help.lines.first
  end

  def test_first_argument_is_an_input_file
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M schema.json other.json])

    assert_empty cli.params.errors.to_a
    assert_equal %w[schema.json other.json], Array(cli.params[:input])
  end

  def test_generators_as_last_option_leaves_input_files_alone
    cli = Schematrix::CLI.new
    cli.parse(%w[-m M -o out -g plain_ruby schema.json other.json])

    assert_empty cli.params.errors.to_a
    assert_equal ["plain_ruby"], Array(cli.params[:generators])
    assert_equal %w[schema.json other.json], Array(cli.params[:input])
  end

  def test_generators_accept_a_comma_separated_list
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby,rbs -m M schema.json])

    assert_empty cli.params.errors.to_a
    assert_equal %w[plain_ruby rbs], Array(cli.params[:generators])
  end

  def test_generators_option_is_repeatable
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -g rbs -m M schema.json])

    assert_empty cli.params.errors.to_a
    assert_equal %w[plain_ruby rbs], Array(cli.params[:generators])
  end

  def test_generators_value_with_only_delimiters_is_invalid
    cli = Schematrix::CLI.new
    cli.parse(%w[-g ,,, -m M schema.json])

    refute_empty cli.params.errors.to_a
  end

  def test_schema_dir_option_is_repeatable
    cli = Schematrix::CLI.new
    cli.parse(
      %w[
        -g
        plain_ruby
        -m
        M
        --schema-dir
        vendor/schemas
        --schema-dir
        local/schemas
        schema.json
      ],
    )

    assert_empty cli.params.errors.to_a
    assert_equal %w[vendor/schemas local/schemas],
                 Array(cli.params[:schema_dir])
  end

  def test_schema_dir_defaults_to_vendor_schemas
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M schema.json])

    assert_equal %w[vendor/schemas], cli.send(:resolved_schema_dirs)
  end

  def test_explicit_schema_dir_replaces_the_default
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M --schema-dir local/schemas schema.json])

    assert_equal %w[local/schemas], cli.send(:resolved_schema_dirs)
  end

  def test_unknown_generator_is_fatal
    cli = Schematrix::CLI.new
    cli.parse(%w[-g nope -m M schema.json])

    assert_output(nil, /Unknown generators: nope/) do
      assert_raises(SystemExit) { cli.run }
    end
  end

  def test_enums_option_parses
    %w[classes unions].each do |mode|
      cli = Schematrix::CLI.new
      cli.parse(["-g", "plain_ruby", "-m", "M", "--enums", mode, "schema.json"])

      assert_empty cli.params.errors.to_a
      assert_equal mode, cli.params[:enums]
    end
  end

  def test_enums_default_is_unset_for_pipeline_resolution
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M schema.json])

    assert_empty cli.params.errors.to_a
    assert_nil cli.params[:enums]
  end

  def test_invalid_enums_mode_is_fatal
    previous_logger = Schematrix.logger
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M --enums scalar schema.json])

    assert_output(nil, /Unknown enums mode: scalar/) do
      error = assert_raises(SystemExit) { cli.run }
      assert_equal 1, error.status
    end
  ensure
    Schematrix.logger = previous_logger
  end

  def test_enums_default_and_explicit_override_reach_generated_types
    previous_logger = Schematrix.logger
    schema = File.join(__dir__, "fixtures", "enum_usage", "schema.json")
    [
      ["rbs", [], '("active" | "inactive")?'],
      ["rbs,rbs_enums", [], "Schema::Props::Status?"],
      ["rbs,rbs_enums", %w[--enums unions], '("active" | "inactive")?'],
      ["rbs,rbs_enums", %w[--enums classes], "Schema::Props::Status?"],
    ].each do |generators, options, type|
      Dir.mktmpdir do |output|
        cli = Schematrix::CLI.new
        cli.parse(["-g", generators, "-m", "M", "-o", output, *options, schema])
        assert_empty cli.params.errors.to_a
        cli.run

        source = File.read(File.join(output, "schema.rbs"))
        assert_includes source, "attr_accessor status: #{type}"
        enum_files = Dir["#{output}/**/status.rbs"]
        assert_equal generators.include?("rbs_enums") ? 1 : 0, enum_files.size
      end
    end
  ensure
    Schematrix.logger = previous_logger
  end

  def test_immutable_flag_parses
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M --immutable schema.json])

    assert_empty cli.params.errors.to_a
    assert_equal true, cli.params[:immutable]
  end

  def test_immutable_defaults_to_false
    cli = Schematrix::CLI.new
    cli.parse(%w[-g plain_ruby -m M schema.json])

    assert_empty cli.params.errors.to_a
    assert_equal false, cli.params[:immutable]
  end
end
