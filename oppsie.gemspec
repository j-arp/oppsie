# coding: utf-8
puts "go"
puts `git ls-files -z`.split("\x0")
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oppsie/version'
Gem::Specification.new do |spec|
  spec.name          = "oppsie"
  spec.version       = Oppsie::VERSION
  spec.authors       = ["Jonathan Arp"]
  spec.email         = ["jarp@nd.edu"]
  spec.summary       = "Rake tasks for deploying to Opsworks"
  spec.description   = "Installs rake tasks to easily deploy and/or branch deploy to AWS Opsworks"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
