# Ensure we require the local version and not one we might have installed already
spec = Gem::Specification.new do |s|
  s.name = 'nagira'
  s.version = File.read('version.txt').strip
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

  s.required_ruby_version = '>= 2.0.0'

  s.files = ( %w{ bin/nagira History.md Rakefile version.txt} +
              Dir.glob("{app,lib,spec,config,test}/**/*")
             ).uniq

  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'nagira' << 'nagira-setup'
  s.default_executable = 'nagira'
  # GEMS

  s.add_dependency 'activemodel', '~> 3.2'
  s.add_dependency 'activesupport', '~> 3.2'
  s.add_dependency 'json', '~> 1.8'
  s.add_dependency 'rspec', '~> 3.4'
  s.add_dependency 'sherlock_os', '~> 0.0'
  s.add_dependency 'rspec-core', '~> 3.1'
  s.add_dependency 'rspec-expectations', '~> 3.1'
  s.add_dependency 'rspec-mocks', '~> 3.1'
  s.add_dependency 'ruby-nagios','~> 0.2', ">= 0.2.2"
  s.add_dependency 'sinatra', '~> 1.4'
  s.add_dependency 'sinatra-contrib', '~> 1.4'
  s.add_dependency 'rake', '~> 10.1'
  s.add_dependency 'puma', '~> 2.1'



  # Dev
  s.add_development_dependency "growl", "~> 1"
  s.add_development_dependency "pry", "~> 0.10"
  s.add_development_dependency "guard-brakeman", "~> 0.5"
  s.add_development_dependency "guard-rspec", "~> 4"
  s.add_development_dependency 'yard', "~> 0.8"
  # redcarpet fails in jruby
  s.add_development_dependency 'redcarpet', '~> 3.0' unless RUBY_ENGINE == 'jruby'
end
