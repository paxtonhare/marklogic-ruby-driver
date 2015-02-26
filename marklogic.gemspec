# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marklogic/version'

Gem::Specification.new do |spec|
  spec.name          = 'marklogic'
  spec.version       = Marklogic::VERSION
  spec.authors       = ['Paxton Hare']
  spec.email         = ['paxton@greenllama.com']
  spec.summary       = %q{A Ruby Driver for MarkLogic}
  spec.description   = %q{A Ruby Driver for MarkLogic}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.has_rdoc        = 'yard'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'net-http-digest_auth'
  spec.add_dependency 'activesupport',   '>= 3.1.0'
end
