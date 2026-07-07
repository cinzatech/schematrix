#!/usr/bin/env ruby
# frozen_string_literal: true

# Profiles the library itself with stackprof by repeatedly running every
# fixture schema through the compiler and all generators. No test framework
# involved, so speedscope's left-heavy view groups by library code paths.
#
# Usage:
#   ruby profile_fixtures.rb [output.json] [iterations]
#
# View the result at https://www.speedscope.app or with `npx speedscope`.

# Load stackprof from system gems *before* activating the bundle, since it
# is intentionally not part of the project's Gemfile.
require 'stackprof'
require 'json'

# Now restrict the load path to the project's locked dependencies.
require 'bundler/setup'

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'schematrix'
require 'schematrix/generators/base'

output = ARGV.first&.end_with?('.json') ? ARGV.shift : 'fixtures_profile.json'
iterations = Integer(ARGV.shift || 20)

schemas = Dir[File.expand_path('test/fixtures/*/schema.json', __dir__)].sort
abort 'No fixture schemas found' if schemas.empty?

errors = Hash.new(0)

# Everything up to here (requires, globbing) stays out of the profile.
StackProf.start(mode: :wall, raw: true, interval: 200)

iterations.times do
  schemas.each do |schema_file|
    objects = Schematrix::Compiler.new.compile([schema_file])

    objects.each do |locator, node|
      Schematrix::GENERATORS.each_value do |generator_class|
        generator = generator_class.new('/tmp', 'M', format: false)
        uri = URI(locator)
        generator.transform(uri, generator.class_name_from_path(uri), node)
      rescue StandardError => e
        errors["#{File.basename(File.dirname(schema_file))}: #{e.class}"] += 1
      end
    end
  rescue StandardError => e
    errors["#{File.basename(File.dirname(schema_file))} (compile): #{e.class}"] += 1
  end
end

StackProf.stop
File.write(output, JSON.generate(StackProf.results))

puts "#{iterations} iterations over #{schemas.size} schemas"
errors.each { |what, count| warn "  skipped #{what} x#{count / iterations}" } if errors.any?
puts "Profile written to #{output} (stackprof JSON, speedscope-compatible)"
