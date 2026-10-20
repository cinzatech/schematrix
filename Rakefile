require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/test_*.rb"]
end

task default: :test

require "rdoc/task"
RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("README.md", "lib/**/*.{rb,erb}")
end

namespace :meta do
  desc "Regenerate lib/schematrix/meta from the vendored 2020-12 metaschema"
  task :generate do
    require_relative "lib/schematrix"
    require_relative "lib/schematrix/generators/base"
    require "fileutils"

    root = __dir__
    output = File.join(root, "lib/schematrix/meta")
    metaschema =
      File.join(root, "vendor/schemas/json-schema.org/draft/2020-12/schema")

    FileUtils.rm_rf(output)
    Schematrix.generate(
      generators: [
        Schematrix::Generators::PlainRuby.new(output, "Schematrix::Meta"),
      ],
      input_files: [metaschema],
    )
    puts "Regenerated #{output}"
  end
end
