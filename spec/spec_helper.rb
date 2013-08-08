$: << File.dirname(__FILE__) + '/../lib/'
require_relative '../lib/nagira.rb'
require_relative '../lib/app.rb'
require 'rack/test'

IMPLEMENTED = {
  top:            %w{ _api _status _objects _config _runtime},
  output:          %w{ _list _state _full }, # Type of requests as in varaible @output
  hosts:          %w{ archive tv },
  status:         %w{ _services _servicecomments _hostcomments }
}

RANDOM = %w{ _bla _foo bla foo ahdhjdjda }
