# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'toggl/worktime/version'

Gem::Specification.new do |spec|
  spec.name          = 'toggl-worktime'
  spec.version       = Toggl::Worktime::VERSION
  spec.authors       = ['Tomoya KABE']
  spec.email         = ['limit.usus@gmail.com']

  spec.summary       = 'Summarise Toggl Time Entries',
                       spec.description   = 'Summarise Toggl Time Entries',
                       spec.homepage      = 'https://github.com/limitusus/toggl-worktime'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'togglv8'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rb-readline'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
