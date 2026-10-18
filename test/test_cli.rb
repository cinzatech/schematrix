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
    assert_generate_receives_schema_dirs(
      %w[-g plain_ruby -m M schema.json],
      %w[vendor/schemas],
    )
  end

  def test_explicit_schema_dir_replaces_the_default
    assert_generate_receives_schema_dirs(
      %w[-g plain_ruby -m M --schema-dir local/schemas schema.json],
      %w[local/schemas],
    )
  end

  def test_unknown_generator_is_fatal
    cli = Schematrix::CLI.new
    cli.parse(%w[-g nope -m M schema.json])

    assert_raises(SystemExit) { cli.run }
  end

  private

  # Runs the CLI with Schematrix.generate replaced by a capture, and
  # asserts which schema directories were passed through.
  def assert_generate_receives_schema_dirs(argv, expected)
    cli = Schematrix::CLI.new
    cli.parse(argv)

    captured = nil
    original = Schematrix.method(:generate)
    Schematrix.define_singleton_method(:generate) do |**kwargs|
      captured = kwargs
    end
    cli.run
  ensure
    Schematrix.define_singleton_method(:generate, original)

    assert_equal expected, captured[:schema_dirs]
  end
end
