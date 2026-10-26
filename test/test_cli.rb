require_relative "test_helper"
require_relative "../lib/schematrix/cli"

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
end
