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
end
