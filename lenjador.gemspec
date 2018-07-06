# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = RUBY_PLATFORM =~ /java/ ? 'lenjador-jruby' : 'lenjador'
  gem.version       = '1.3.0'
  gem.authors       = ['Salemove']
  gem.email         = ['support@salemove.com']
  gem.description   = "It's lenjadoric"
  gem.summary       = 'What description said'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'lru_redux'

  if RUBY_PLATFORM =~ /java/
    gem.add_dependency 'jrjackson'
  else
    gem.add_dependency 'oj'
    gem.add_development_dependency 'ruby-prof'
  end

  gem.add_development_dependency 'benchmark-ips'
  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop-salemove'
end
