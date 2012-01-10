#!/usr/bin/env ruby
$: << File.dirname(__FILE__)
require 'sinatra'
require "sinatra/reloader" if development?
require 'lib/ruby-nagios/nagios'
require 'lib/nagira'

require 'active_support' # for Hash.extract!

require 'json'
require 'yaml'
require 'active_model/serialization'
require 'active_model/serializers/xml' # for Hash.to_xml


disable :protection

#  Regex for available formats: xml, json, yaml
FORMAT_EXTENSION = '\.(json|yaml|xml)$'
DEFAULT_FORMAT = :xml


# Parse status file.
# TODO: Add check for file changed? and min parsing interval to avoid
# file paring on each HTTP request.
before do 
  $nagios ||= Nagios::Status.new("/Users/dmytro/Development/nagira/lib/ruby-nagios/test/data/status.dat")
  $nagios.parse if $nagios.need_parsing?
  @data   = $nagios.status['hosts']
end

# Strip extension (@format) from HTTP route
before do 
  request.path_info.sub!(/#{FORMAT_EXTENSION}/, '')
  @format = ($1 || DEFAULT_FORMAT).to_sym
  content_type "application/#{@format.to_s}"
end

# Find output type (@output) if provided: :list, :state or :full
before do
  request.path_info.sub!(/\/(list|state)$/, '')
  @output = ($1 || :full).to_sym
end

# Return 404 if data array is empty.
after do
  if response.body.empty?
    halt [404, {:message => "Object not found or bad request", :error => "HTTP::Notfound"}.send("to_#{@format}")]
  end
end


=begin rdoc

Routes to get service information.
Every route can optionally end with "/list" or "/state" and format specifier <.FORMAT_EXTENSION>

* /list option produces only list of hosts/sevices
* /state - gives short status of host or service
* if none are provided, then will print out full parsed hash 


Following routes are implemented

== Hosts
/status - full list of all hosts with service(s) information
/status.xml
/status/list - list of hosts
/status/list.xml

Service
/status/<hostname>
/status/<hostname>/services(/(list|state).FORMAT_EXTENSION?)?
/status/<hostname>/services/<service name>

=end


get "/status/:hostname/services/:service_name" do |hostname,service|
  body (if @output == :state
          @data[hostname]['servicestatus'][service].extract!("hostname", "service_description", "current_state")
        else
          @data[hostname]['servicestatus'][service]
        end).send("to_#{@format}")
end

# All services for single host: 
# :full, :state or :list
get "/status/:hostname/services" do |hostname|
  data = case @output
         when :list
           @data[hostname]['servicestatus'].keys
         when :state
           @data.each { |k,v| @data[k] = v.extract!("host_name", "service_description", "current_state") }
         else
           @data[hostname]['servicestatus']
         end
  body data.send("to_#{@format}")
end
  
# Hoststatus for single host
# - :state - hostname and current_state
# - :full  - full hoststatus
get "/status/:hostname" do |hostname|
  body (if @output == :state
          @data[hostname]['hoststatus'].extract!("host_name", "current_state")
        else
          @data[hostname]['hoststatus']
        end).send("to_#{@format}")
end

#
# All hosts status
# - :state - only hostname and current_state
# - :list  - list of hostnames
# - :full status of all hosts and services
# 
get "/status" do
  case @output 
  when :state
    @data.each { |k,v| @data[k] = v['hoststatus'].extract!("host_name", "current_state") }
  when :list
    @data = @data.keys
  end
  body @data.send("to_#{@format}")
end


# TODO: provide informatiuon about API routes
get "/api" do 
  [501, "TODO: Not implemented"]
end

# Other resources in parsed status file. Supported are => ["hosts",
# "info", "process", "contacts"]
get "/:resource" do |resource|
  respond_with $nagios.status[resource], @format
end


# Process informaton, same as get /process above. With default format
# only.
get '/' do
  respond_with $nagios.status['process'], nil
end


