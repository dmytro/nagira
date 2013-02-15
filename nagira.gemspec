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
  s.description = ""

  s.files = ( %w{ nagira.rb version.txt spec/00_configuration_spec.rb } + 
              Dir.glob("./app/**/*.rb") + 
              Dir.glob("./lib/**/*.rb") + 
              Dir.glob("./config/*.rb")
             ).uniq

  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.md']
  s.rdoc_options << '--title' << 'Nagira' << '--main' << 'README.md' << '-ri'
  s.bindir = 'bin'
  s.executables << 'nagira.rb'
  s.add_dependency('nagios')
  s.add_development_dependency('rake')
  s.add_development_dependency('yard')
end
