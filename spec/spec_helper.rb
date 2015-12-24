require_relative '../app/app.rb'
require 'rack/test'

IMPLEMENTED = {
  top:            %w{ _api _status _objects _config _runtime},
  output:          %w{ _list _state _full }, # Type of requests as in varaible @output
  hosts:          %w{ archive tv },
  hostgoups:      %w{ all linux },
  status:         %w{ _services _servicecomments _hostcomments}
}

RANDOM = %w{ _bla _foo bla foo ahdhjdjda }

class Nagira < Sinatra::Base
  set :environment, ENV['RACK_ENV'] || :test
end

def dont_run_in_production(file)
  if Nagira.settings.environment == :production
    puts "**** #{File.basename file} should not be run in #{Nagira.settings.environment} environment"
    return true
  end
  false
end
