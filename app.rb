#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'sinatra'
require "sinatra/reloader" if development?
require 'lib/ruby-nagios/nagios'
require 'json'
require 'yaml'
require 'active_model/serialization'
require 'active_model/serializers/xml'
require 'lib/nagira'


disable :protection

before do 
  @nagios = Nagios::Status.new("/Users/dmytro/Development/nagira/lib/ruby-nagios/test/data/status.dat").parse
end

#  Regex for available formats: xml, json
format_rex = '(json|yaml|xml)'

# Regex for hostname, including FQDN
hostname_rex = '(\w[\w\-\.]+)'

#
# /hosts/hostname/services/list(.ext)?
#
get %r{^/hosts/#{hostname_rex}/services/list\.?#{format_rex}?$} do |hostname,format|
  respond_with(@nagios.status['hosts'][hostname]['servicestatus'].keys, format) rescue respond_with nil,format
end

#
# /hosts/hostname/services(.ext)?
#
get %r{^/hosts/#{hostname_rex}/services\.?#{format_rex}?$} do |hostname,format|
  respond_with(@nagios.status['hosts'][hostname]['servicestatus'], format) rescue respond_with nil,format
end

#
# /hosts/hostname/services/list(.ext)?
#
get %r{^/hosts/#{hostname_rex}/services/list\.?#{format_rex}?$} do |hostname,format|
  respond_with(@nagios.status['hosts'][hostname]['servicestatus'].keys, format) rescue respond_with nil,format
end

#
# /hosts/hostname(.ext)?
#
get %r{^/hosts/#{hostname_rex}\.?#{format_rex}?$} do |hostname,format|
  respond_with(@nagios.status['hosts'][hostname]['hoststatus'], format) rescue respond_with nil,format
end


get %r{^/([\w]+)\.?#{format_rex}?$} do |resource,format|
  respond_with @nagios.status[resource], format
end

# Process informaton
get '/' do
  respond_with @nagios.status['process'], nil
end


