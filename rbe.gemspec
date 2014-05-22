# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rbe/version'

Gem::Specification.new do |spec|
  spec.name          = 'rbe'
  spec.version       = Rbe::VERSION
  spec.authors       = ['Eric Henderson']
  spec.email         = ['henderea@gmail.com']
  spec.summary       = %q{RuBy Executor}
  spec.description   = %q{A tool for making it easier to run common commands.  Supports storing and automatically filling in your sudo password. Also supports saving common commands and calling them by name.  Groups of commands can also be saved and called by name.}
  spec.homepage      = 'https://github.com/henderea/rbe'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'

  spec.add_dependency 'everyday-cli-utils', '~> 1.7'
  spec.add_dependency 'everyday-plugins', '~> 1.2'
  spec.add_dependency 'everyday_thor_util', '~> 1.5', '>= 1.5.3'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'ruby-keychain', '~> 0.1'
end