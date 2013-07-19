# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','nagira','version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'nagira'
  s.version = Nagira::VERSION
  s.license = 'MIT'
  s.author = 'Dmytro Kovalov'
  s.email = 'dmytro.kovalov@gmail.com'
  s.homepage = 'http://dmytro.github.com/nagira'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Nagira : Nagios RESTful API'
  s.description =<<-EOF

Nagira -- Nagios RESTful API

Web services API for Nagios: host status (R/W), service status (R/W);
read-only access to configuration objects: hosts, services, contacts,
escalations; read-only Nagios server configuration and Nagios runtime
environment

EOF

  s.files = ( %w{ bin/nagira History.md Rakefile version.txt} + 
              Dir.glob("{app,lib,spec,config,test}/**/*")
             ).uniq

  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'nagira' << 'nagira-setup'
  s.default_executable = 'nagira'
  # GEMS
  
  s.add_dependency 'activemodel', '~> 3.2.13'
  s.add_dependency 'activesupport', '~> 3.2.13'
  s.add_dependency 'json', '>= 1.7.7'
  s.add_dependency 'rspec'
  s.add_dependency 'sherlock_os', '~> 0.0.2'
  s.add_dependency 'rspec-core'
  s.add_dependency 'rspec-expectations'
  s.add_dependency 'rspec-mocks'
  s.add_dependency 'ruby-nagios', "~> 0.2.0"
  s.add_dependency 'sinatra', '~> 1.3.6'
  s.add_dependency 'sinatra-contrib', '~> 1.3.2'
  s.add_dependency 'rake'

  
  
  # Dev
  s.add_development_dependency "growl", "~> 1.0.3"
  s.add_development_dependency "guard-brakeman", "~> 0.5.0"
  s.add_development_dependency "guard-rspec", "~> 1.2.1"
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'yard', "~> 0.8"
  # redcarpet fails in jruby
  s.add_development_dependency 'redcarpet' unless RUBY_ENGINE == 'jruby'
end
