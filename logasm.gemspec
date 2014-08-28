# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "logasm"
  spec.version       = '0.0.2'
  spec.authors       = ["Markus Mühle"]
  spec.email         = ["markus@salemove.com"]
  spec.description   = %q{Logging gem}
  spec.summary       = %q{ya}
  spec.license       = "Private"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "bunny", "~> 1.3"
  spec.add_dependency "logstash-logger", "~> 0.6.0"
end
