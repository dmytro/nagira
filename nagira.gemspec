# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','nagira.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'nagira'
  s.version = Nagira::VERSION
  s.author = 'Dmytro Kovalov'
  s.email = 'dmytro.kovalov@gmail.com'
  s.homepage = 'http://dmytro.github.com/nagira'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Nagira : Nagios RESTful API'
  s.description =<<-EOF

Nagira -- Nagios RESTful API
============================

Description
------------

Light-weight web services RESTful API for reading and changing
status of Nagios objects: host status service status and for
read-only access to: Nagios objects hosts services, contacts,
groups of hosts services contacts escalations, etc., to Nagios
server configuration and to Nagios runtime environment

EOF

  s.files = ( %w{ bin/nagira Rakefile version.txt} + 
              Dir.glob("{app,lib,spec,config}/**/*")
             ).uniq

  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'nagira'
  # GEMS
  
  s.add_dependency 'activemodel'
  s.add_dependency 'activesupport'
  s.add_dependency 'json'
  s.add_dependency 'rspec'
  s.add_dependency 'rspec-core'
  s.add_dependency 'rspec-expectations'
  s.add_dependency 'rspec-mocks'
  s.add_dependency 'ruby-nagios', ">= 0.1.0"
  s.add_dependency 'sinatra', '>= 1.3.1'
  
  # Dev
  s.add_development_dependency "growl", "~> 1.0.3"
  s.add_development_dependency "guard-brakeman", "~> 0.5.0"
  s.add_development_dependency "guard-rspec", "~> 1.2.1"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'sinatra-contrib', '>= 1.3.1'
  s.add_development_dependency 'yard', "~> 0.8"
end
