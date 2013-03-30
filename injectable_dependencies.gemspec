# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'injectable_dependencies/version'

Gem::Specification.new do |spec|
  spec.name          = "injectable_dependencies"
  spec.version       = InjectableDependencies::VERSION
  spec.authors       = ["John Wilger"]
  spec.email         = ["johnwilger@gmail.com"]
  spec.description   = %q{Lightweight Ruby Dependency Injection}
  spec.summary       = %q{Make your object's collaborators injectable so you can test them.}
  spec.homepage      = "http://github.com/jwilger/injectable_dependencies"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
