# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'lenjador'
  gem.version       = '2.2.1'
  gem.authors       = ['Salemove']
  gem.email         = ['support@salemove.com']
  gem.description   = "It's lenjadoric"
  gem.summary       = 'What description said'
  gem.license       = 'MIT'
  gem.required_ruby_version = '>= 2.4'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'lru_redux'
  gem.add_dependency 'oj', '~> 3.6'

  gem.add_development_dependency 'benchmark-ips'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'opentelemetry-api'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop-salemove'
  gem.add_development_dependency 'ruby-prof'
end
