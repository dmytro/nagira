$: << File.dirname(__FILE__) + '/../lib/'
require_relative '../lib/nagira.rb'
require_relative '../lib/app.rb'
require 'rack/test'

IMPLEMENTED = {
  top:            %w{ _api _status _objects _config _runtime},
  output:          %w{ _list _state _full }, # Type of requests as in varaible @output
  hosts:          %w{ tv archive },
#  status:         %w{ _services _list _state _full _servicecomments _hostcomments _hosts }
  status:         %w{ _services _list _state _full }
}

RANDOM = %w{ _bla _foo bla foo ahdhjdjda }
