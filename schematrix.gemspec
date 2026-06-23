Gem::Specification.new do |s|
  s.name        = 'schematrix'
  s.version     = '0.1.0'
  s.summary     = 'Generate Ruby from JSON Schema'
  s.description = 'Generate Ruby code and RBS signatures from JSON Schema definition'
  s.authors     = ['Cinza']
  s.email       = 'cinza@lostrego.org'
  s.files = Dir['lib/**/*.rb', 'exe/**/*', 'README.md', 'LICENSE']
  s.homepage =
    'https://github.com/cinzatech/schematrix'
  s.license = 'AGPL-3.0-or-later'
  s.required_ruby_version = '>= 3.1'

  s.bindir = 'exe'
  s.executables = s.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'syntax_tree', '~> 6.3'
  s.add_dependency 'tty-logger', '~> 0.6.0'
  s.add_dependency 'tty-option', '~> 0.3.0'
end
