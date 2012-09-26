#!/usr/bin/env ruby

# @!macro  [attach] sinatra.get
#
#    @overload get "$1"
#
#    @return HTTP response. Hash formatted in the format defined by
#         requested output type(XML, YAML or JSON).
#
#
#
# @!macro [new] type
#     @param [String] :type Type is one of Nagios objects like  hosts, hostgroupsroups, etc.
#
# @!macro [new] name
#       @param [String] :name
#
# @!macro [new] hostname
#   @param [String] :hostname Configured Nagios hostname
#
# @!macro [new] service_name
#   @param [String] :service_name Configured Nagios service for the host
#
# @!macro [new] accepted 
#
#    <b>Accepted output type modifiers:</b>
#
# @!macro [new] list 
#
#     - +/_list+ : Short list of available objects, depending on the
#       current request context: hosts, services, etc.
#
# @!macro [new] state 
#
#     - +/_state+ - Instead of full status information send only
#       current state. For hosts up/down, for services OK, Warn,
#       Critical, Unknown (0,1,2-1)
#
# @!macro [new] full
#
#     - +/_full+ - Show full status information
#       TODO Not implemented
#


$: << File.dirname(__FILE__)
require 'lib/nagira'

##
# Main class of Nagira application implementing RESTful API for
# Nagios.
#
class Nagira < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  set :app_file, __FILE__

  ##
  # Parse nagios files.
  #
  # Note: *.parse methods are monkey-patched here (if you have required
  # 'lib/nagira' above) to set min parsing interval to avoid file paring
  # on each HTTP request. File is parsed only if it was changed and if
  # it was parsed more then 60 (default) seconds ago. See
  # +lib/nagira/timed_parse.rb+ for mor more info.
  #
  # In development mode use files located under +./test/data+
  # directory. This allows to do development on the host where Nagios is
  # notinstalled. If you want to change this edit configuration in
  # config/environment.rb file.
  #
  # See also comments in config/default.rb file regarding nagios_cfg,
  # status_cfg, objects_cfg.
  #
  # @method   parse_nagios_files
  # @overload before("parse Nagios files")

  before do 

    $nagios ||= { :config => nil, :status => nil, :objects => nil }
    
    $nagios[:config]  ||= Nagios::Config.new Nagira.settings.nagios_cfg
    $nagios[:config].parse

    $nagios[:status]  ||= Nagios::Status.new(  settings.status_cfg || 
                                               $nagios[:config].status_file
                                               )
    $nagios[:objects] ||= Nagios::Objects.new( settings.objects_cfg || 
                                               $nagios[:config].object_cache_file
                                               )
    $nagios[:status].parse
    $nagios[:objects].parse

    @status   = $nagios[:status].status['hosts']
    @objects  = $nagios[:objects].objects
  end

  ##
  # @method     clear_instance_data
  # @overload before("clear data")
  #
  # Clear values onf instance variables before start.
  #
  before do 
    @data = []
    @format = @output = nil
  end

  ##
  # @method     strip_extensions  
  # @overload before("detect format")
  #
  # Detect and strip output format extension
  #
  # Strip extension (@format) from HTTP route and set it as instance
  # variable @format. Valid formats are .xml, .json, .yaml. If format
  # is not specified, it is set to default format
  # (Nagira.settings.format).
  #
  # \@format can be assigned one of the symbols: :xml, :json, :yaml.
  #
  # = Examples
  # 
  #     GET /objects             # => default format
  #     GET /objects.json        # => :json
  #     GET /status/list.yaml    # => :yaml
  # 
 before do 
    request.path_info.sub!(/#{settings.format_extensions}/, '')
    @format = ($1 || settings.format).to_sym
    content_type "application/#{@format.to_s}"
  end

  ##
  # @method   strip_output_type 
  # @overload before('detect output mode')
  #
  # Detect output mode modifier
  #
  # Detect and strip output type from HTTP route. Full list of
  # output types is +:list+, +:state+ or +:full+, corresponding to
  # (+/list, +/state+, +/full+ routes).
  #
  # Output type defined by route modifier appended to the end of HTTP
  # route. If no output type specfied it is set to +:full+. Output
  # mode can be followed by format extension (+.json+, +.xml+ or
  # +.yaml+).
  #
  # = Examples
  #
  #     GET /_objects/_list     # => :list
  #     GET /_status/_state     # => :state
  #     GET /_status/:hostname  # => :full
  #     GET /_status            # => :full
  #
  before do
    request.path_info.sub!(/\/_(list|state)$/, '')
    @output = ($1 || :full).to_sym
  end

  ##
  # @method find_jsonp_callback
  # @overload before('find callback name')
  # 
  # Detects if request is using jQuery JSON-P and sets @callback
  # variable. @callback variable is used if after method and prepends
  # JSON data with callback function name.
  #
  # = Example
  #
  # GET /api?callback=jQuery12313123123 # @callback == jQuery12313123123
  #
  # JSONP support is based on the code from +sinatra/jsonp+ Gem
  # https://github.com/shtirlic/sinatra-jsonp.
  #
  before do
    if @format == :json
      ['callback','jscallback','jsonp','jsoncallback'].each do |x|
        @callback = params.delete(x) unless @callback
      end
    end
  end

  ##
  # @method   object_not_found
  # @overload after("Object not found or bad request")
  #
  # If result-set of object/status search is empty return HTTP 404 .
  # This can happen when you are requesting status for not existing
  # host and/or service.
  #
  #
  after do
    if ! @data || @data.empty?
      halt [404, {
              :message => "Object not found or bad request", 
              :error => "HTTP::Notfound"
            }.send("to_#{@format}")
           ]
    end
  end

  ##
  # @method   return_jsonp_data
  # @overload after("Return JSON-P formatted data")
  #
  # If it's a JSON-P request, return its data with prepended @callback
  # function name. JSONP request is detected by +before+ method.
  #
  # = Example
  #
  #     $ curl  'http://localhost:4567/?callback=test'
  #         test(["{\"application\":\"Nagira\",\"version\":\"0.1.3\",\"url\":\"http://dmytro.github.com/nagira/\"}"])
  #
  after do
    body( @callback ? "#{@callback.to_s} (#{@data})" : @data.send("to_#{@format}") )
  end

  # Config routes
  # ============================================================

  # @!macro  [attach] sinatra.get
  #
  #    @overload get "$1"
  #
  #    @return HTTP response. Hash formatted in the format defined by
  #         requested output type(XML, YAML or JSON).
  #
  #
  # @method get_config
  # Get Nagios configuration.
  #
  # Get Nagios configuration hash form parsing main Nagios
  # configuration file nagios.cfg
  get "/_config" do
    @data = $nagios[:config].configuration
    nil
  end
  
  #
  # Objects routes
  # ============================================================

  ##
  # @method get_objects
  #
  # Get full list of Nagios objects. Returns hash containing all
  # configured objects in Nagios: hosts, hostgroups, services,
  # contacts. etc.
  #
  # @macro accepted
  # @macro list
  #
  get "/_objects" do
    
    @data = begin
              @output == :list ? @objects.keys : @objects
            rescue NoMethodError 
              nil
            end
    nil
  end

  ##
  # @method   get_object_type
  # @!macro type
  #
  # Get all objects of type :type
  #
  # @!macro accepted
  # @!macro list
  # 
  #
  get "/_objects/:type" do |type|
    begin
      @data = @objects[type.to_sym]
      @data = @data.keys if @output == :list
    rescue NoMethodError
      nil
    end

    nil
  end

  ##
  # @method get_1_object
  #
  # Get single Nagios object.
  #
  # @!macro type
  # @!macro name
  #
  # @!macro accepted
  # * none
  #
  get "/_objects/:type/:name" do |type,name|
    begin
      @data = @objects[type.to_sym][name]
    rescue NoMethodError
      nil
    end

    nil
  end


  # Status routes
  # ============================================================

  ##
  # @method get_status_hostname_services_service_name
  #
  # @!macro hostname
  # @!macro service_name
  #
  # Full or short status information for single service on single
  # host.
  #
  # @!macro accepted
  # @!macro state
  #
  get "/_status/:hostname/_services/:service_name" do |hostname,service|

    if @output == :state
      @data = @status[hostname]['servicestatus'][service].slice("hostname", "service_description", "current_state")
    else
      @data = @status[hostname]['servicestatus'][service]
    end
    nil
  end

  ##
  # @method get_status_hostname_services
  # @!macro hostname
  #
  # All services for single host.
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  get "/_status/:hostname/_services" do |hostname|

    case @output
    when :list
      @data = @status[hostname]['servicestatus'].keys
    when :state
      @data = @status.each { |k,v| @data[k] = v.slice("host_name", "service_description", "current_state") }
    else
      @data = @status[hostname]['servicestatus']
    end

    nil
  end
  
  # Hoststatus for single host
  #
  # @method get_status_hostname
  #
  # @!macro hostname
  #
  # @!macro accepted
  # @!macro state
  #
  get "/_status/:hostname" do |hostname|
    @data = @status[hostname]['hoststatus'].dup

    if @output == :state
      @data = @data.slice("host_name", "current_state")
    end

    nil
  end

  ##
  # @method get_status
  #
  # All hosts status.
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  #
  get "/_status" do
    @data = @status.dup

    case @output 
    when :state
      @data.each { |k,v| @data[k] = v['hoststatus'].slice("host_name", "current_state") }
    when :list
      @data = @data.keys
    end

    nil
  end


  ##
  # @method get_api
  #
  # Provide information about API routes 
  #
  get "/_api" do 
    @data = self.api
    nil
  end

  # 
  get "/" do
    @data = {
      :application => self.class,
      :version => VERSION,
      :source => GITHUB,
      :apiUrl => "/api"
    }
    nil
  end
  # Other resources in parsed status file. Supported are => ["hosts",
  # "info", "process", "contacts"]
  # get "/:resource" do |resource|
  #   respond_with $nagios.status[resource], @format
  # end


  # # Process informaton, same as get /process above. With default format
  # # only.
  # get '/' do
  #   respond_with $nagios.status['process'], nil
  # end

  # Start Sinatra application when not running from rack
  run! if app_file == $0
end
