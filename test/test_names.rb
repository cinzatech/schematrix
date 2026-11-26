require_relative "test_helper"
require "tmpdir"

class TestNames < Minitest::Test
  include SchematrixTestHelper

  # Gives each document the module of its directory, with a prefix
  # that keeps the constants of this test apart from other tests.
  class AreaNames < Schematrix::DefaultNames
    def module_name(locator)
      "Names#{URI(locator).path.split("/")[-2].capitalize}"
    end

    def class_name(locator)
      super.sub(/\AApi/, "API")
    end
  end

  class FixedNames
    def initialize(module_name, class_name)
      @module_name = module_name
      @class_name = class_name
    end

    def module_name(_locator) = @module_name

    def class_name(_locator) = @class_name
  end

  G = Schematrix::Generators

  def test_default_names_take_the_module_and_the_file_name
    names = Schematrix::DefaultNames.new("Contracts")
    locator = "file:///schemas/payment-methods.schema.json#/"

    assert_equal "Contracts", names.module_name(locator)
    assert_equal "PaymentMethods", names.class_name(locator)
  end

  def test_each_generator_family_uses_the_names
    with_areas do |dir, inputs|
      out = File.join(dir, "out")
      generators = [
        G::PlainRuby.new(out, "Contracts", names: AreaNames.new("Contracts")),
        G::PlainRubyEnums.new(out, "Contracts"),
        G::DslPlainRuby.new(out, "Contracts"),
        G::DslParser.new(out, "Contracts"),
        G::PartialPlainRuby.new(out, "Contracts"),
      ]

      Schematrix.generate(generators:, input_files: inputs)

      expected = {
        "names_billing/invoice.rb" => "module NamesBilling\n  class Invoice",
        "names_billing/api_key.rb" => "module NamesBilling\n  class APIKey",
        "names_billing/invoice/props/status.rb" =>
          "class Invoice\n    module Props\n      class Status",
        "names_billing/dsl/invoice.rb" =>
          "module NamesBilling\n  module Dsl\n    module Invoice",
        "names_billing/parser/invoice.rb" =>
          "module NamesBilling\n  module Parser\n    module Invoice",
        "names_billing/partial/invoice.rb" =>
          "module NamesBilling\n  class Partial\n    class Invoice",
        "names_shipping/invoice.rb" => "module NamesShipping\n  class Invoice",
        "maybe.rb" => "module Contracts",
        "parser/runtime.rb" => "module Contracts",
      }
      expected.each do |path, declaration|
        assert_includes File.read(File.join(out, path)), declaration, path
      end
    end
  end

  def test_references_across_modules_load_and_run
    with_areas do |dir, inputs|
      out = File.join(dir, "out")
      names = AreaNames.new("NamesRoot")
      generators = [
        G::PlainRuby.new(out, "NamesRoot", optionals: :maybe, names:),
        G::PlainRubyEnums.new(out, "NamesRoot"),
        G::DslPlainRuby.new(out, "NamesRoot"),
        G::DslParser.new(out, "NamesRoot"),
        G::AuxiliaryFiles.new(out, "NamesRoot"),
      ]
      Schematrix.generate(generators:, input_files: inputs)
      Dir[File.join(out, "**/*.rb")].each { |file| require file }

      source = <<~RUBY
        NamesBilling::Dsl::Invoice.build do
          status NamesBilling::Invoice::Props::Status::Open
          shipment do
            carrier NamesShipping::Invoice::Props::Carrier::Ups
          end
        end
      RUBY
      document = NamesBilling::Parser::Invoice.parse(source)
      invoice = NamesBilling::Invoice.from_h(document)

      assert_equal(
        { "status" => "open", "shipment" => { "carrier" => "ups" } },
        document,
      )
      assert_instance_of NamesShipping::Invoice, invoice.shipment.value
      assert_kind_of NamesRoot::Maybe::Present, invoice.shipment
      assert_equal document, invoice.to_h
    end
  end

  def test_the_names_of_one_generator_apply_to_the_run
    with_areas do |dir, inputs|
      out = File.join(dir, "out")
      generators = [
        G::PlainRuby.new(out, "Contracts"),
        G::Rbs.new(out, "Contracts", names: AreaNames.new("Contracts")),
      ]

      Schematrix.generate(generators:, input_files: inputs)

      assert_path_exists File.join(out, "names_billing/invoice.rb")
      assert_path_exists File.join(out, "names_billing/invoice.rbs")
    end
  end

  def test_two_names_objects_in_one_run_raise
    generators = [
      G::PlainRuby.new("out", "Contracts", names: AreaNames.new("Contracts")),
      G::Rbs.new("out", "Contracts", names: AreaNames.new("Contracts")),
    ]

    error =
      assert_raises(ArgumentError) do
        Schematrix.generate(generators:, input_files: [])
      end
    assert_match(/conflicting names objects/, error.message)
  end

  def test_an_object_without_both_methods_raises_at_construction
    error =
      assert_raises(ArgumentError) do
        G::PlainRuby.new("out", "Contracts", names: Object.new)
      end
    assert_match(/module_name and class_name/, error.message)
  end

  def test_an_invalid_name_stops_the_run_before_the_first_write
    [
      [FixedNames.new("billing", "Invoice"), /module_name.*"billing"/],
      [
        FixedNames.new("Billing", "Billing::Invoice"),
        /class_name.*"Billing::Invoice"/,
      ],
    ].each do |names, message|
      with_areas do |dir, inputs|
        out = File.join(dir, "out")

        error =
          assert_raises(ArgumentError) do
            Schematrix.generate(
              generators: [G::PlainRuby.new(out, "Contracts", names:)],
              input_files: inputs,
            )
          end

        assert_match message, error.message
        assert_match %r{file://.*\.json#/}, error.message
        refute_path_exists out
      end
    end
  end

  def test_two_documents_with_one_name_collide
    with_areas do |dir, inputs|
      out = File.join(dir, "out")

      assert_raises(Schematrix::OutputCollisionError) do
        Schematrix.generate(
          generators: [
            G::PlainRuby.new(
              out,
              "Contracts",
              names: FixedNames.new("Contracts", "Invoice"),
            ),
          ],
          input_files: inputs,
        )
      end
      refute_path_exists out
    end
  end

  def test_an_input_file_that_is_a_remote_ref_target_is_named_once
    Dir.mktmpdir do |dir|
      schemas = File.join(dir, "schemas", "example.com", "billing")
      FileUtils.mkdir_p(schemas)
      money = File.join(schemas, "money.json")
      order = File.join(schemas, "order.json")
      File.write(
        money,
        '{"type":"object","properties":{"cents":{"type":"integer"}}}',
      )
      File.write(
        order,
        '{"type":"object","properties":' \
          '{"total":{"$ref":"https://example.com/billing/money"}}}',
      )
      locators = []
      names = AreaNames.new("Contracts")
      names.define_singleton_method(:class_name) do |locator|
        locators << locator
        super(locator)
      end
      out = File.join(dir, "out")

      Schematrix.generate(
        generators: [G::Rbs.new(out, "Contracts", names:)],
        input_files: [order, money],
        schema_dirs: [File.join(dir, "schemas")],
      )

      assert_empty locators.grep(%r{\Ahttps://})
      assert_equal %w[money.rbs order.rbs],
                   Dir.children(File.join(out, "names_billing")).sort
      assert_includes File.read(File.join(out, "names_billing/order.rbs")),
                      "total: Money?"
    end
  end

  private

  def with_areas
    Dir.mktmpdir do |dir|
      write_schema(
        dir,
        "shipping/invoice.json",
        "type" => "object",
        "properties" => {
          "carrier" => {
            "type" => "string",
            "enum" => %w[ups dhl],
          },
        },
        "required" => ["carrier"],
      )
      write_schema(
        dir,
        "billing/invoice.json",
        "type" => "object",
        "properties" => {
          "status" => {
            "type" => "string",
            "enum" => %w[open paid],
          },
          "shipment" => {
            "$ref" => "../shipping/invoice.json",
          },
        },
        "required" => ["status"],
      )
      write_schema(
        dir,
        "billing/api-key.json",
        "type" => "object",
        "properties" => {
          "key" => {
            "type" => "string",
          },
        },
      )
      yield dir, Dir[File.join(dir, "*/*.json")]
    end
  end

  def write_schema(dir, path, document)
    path = File.join(dir, path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate(document))
  end
end
