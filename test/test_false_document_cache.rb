require_relative "test_helper"
require "tmpdir"

class TestFalseDocumentCache < Minitest::Test
  def test_false_document_is_loaded_once
    Dir.mktmpdir do |dir|
      path = File.join(dir, "schema.json")
      File.write(path, "false\n")
      uri = URI("file://#{path}")
      store = Schematrix::DocumentStore.new
      loads = 0
      reader = store.method(:read_document)
      store.define_singleton_method(:read_document) do |locator|
        loads += 1
        reader.call(locator)
      end
      3.times { assert_equal false, store.node_at(uri) }
      assert_equal 1, loads
    end
  end
end
