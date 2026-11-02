require_relative "test_helper"
require "tmpdir"

class TestDocumentStoreCache < Minitest::Test
  def test_dynamic_anchor_fallback_scans_once_per_document
    Dir.mktmpdir do |dir|
      path = File.join(dir, "schema.json")
      File.write(
        path,
        JSON.generate(
          {
            "$dynamicAnchor" => "root",
            "$defs" => {
              "first" => {
                "$dynamicAnchor" => "shared",
              },
              "last/key" => {
                "$dynamicAnchor" => "shared",
              },
            },
          },
        ),
      )
      uri = URI("file://#{path}")
      store = Schematrix::DocumentStore.new
      scans = 0
      scan = store.method(:each_node)
      store.define_singleton_method(:each_node) do |*args, &block|
        scans += 1
        scan.call(*args, &block)
      end

      3.times do
        assert_equal "/$defs/last%7E1key",
                     store.last_dynamic_anchor_locator(uri, "shared").fragment
        assert_equal "/",
                     store.last_dynamic_anchor_locator(uri, "root").fragment
        assert_nil store.last_dynamic_anchor_locator(uri, "missing")
      end
      assert_equal 1, scans
    end
  end
end
