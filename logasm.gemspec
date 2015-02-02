# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "logasm"
  gem.version       = '0.1.0'
  gem.authors       = ["Salemove"]
  gem.email         = ["support@salemove.com"]
  gem.description   = %q{It's logasmic}
  gem.summary       = %q{What description said}
  gem.license       = "Private"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'logstash-event', '~> 1.2'
  gem.add_dependency 'inflecto'

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
end
