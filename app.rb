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
#     - +/list+ : Short list of available objects, depending on the
#       current request context: hosts, services, etc.
#
# @!macro [new] state 
#
#     - +/state+ - Instead of full status information send only
#       current state. For hosts up/down, for services OK, Warn,
#       Critical, Unknown (0,1,2-1)
#
# @!macro [new] full
#
#     - +/full+ - Show full status information
#       TODO Not implemented
#




$: << File.dirname(__FILE__)
require 'lib/nagira'

##
# Main class of Nagira application implementing RESTful API for
# Nagios.
#
class Nagira < Sinatra::Base

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
    @objects   = $nagios[:objects].objects
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
  #     GET /status/list.yaml    # default format
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
  #     GET /objects/list     # => :list
  #     GET /status/state     # => :state
  #     GET /status/:hostname # => :full
  #     GET /status           # => :full
  #
  before do
    request.path_info.sub!(/\/(list|state)$/, '')
    @output = ($1 || :full).to_sym
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
    if response.body.empty?
      halt [404, {
              :message => "Object not found or bad request", 
              :error => "HTTP::Notfound"
            }.send("to_#{@format}")
           ]
    end
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
  get "/config" do 
    body $nagios[:config].configuration.send("to_#{@format}")
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
  get "/objects" do
    
    body (@output == :list ? 
          @objects.keys.send("to_#{@format}") : 
          @objects.send("to_#{@format}")) rescue NoMethodError nil
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
  get "/objects/:type" do |type|
    begin
      data = @objects[type.to_sym]
      data = data.keys if @output == :list
      body ( data ? data : nil ).send("to_#{@format}")
    rescue NoMethodError
      nil
    end
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
  get "/objects/:type/:name" do |type,name|
    begin
      body @objects[type.to_sym][name].send("to_#{@format}")
    rescue NoMethodError
      nil
    end
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
  get "/status/:hostname/services/:service_name" do |hostname,service|
    body (if @output == :state
            @status[hostname]['servicestatus'][service].extract!("hostname", "service_description", "current_state")
          else
            @status[hostname]['servicestatus'][service]
          end).send("to_#{@format}")
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
  get "/status/:hostname/services" do |hostname|
    data = case @output
           when :list
             @status[hostname]['servicestatus'].keys
           when :state
             @status.each { |k,v| @status[k] = v.extract!("host_name", "service_description", "current_state") }
           else
             @status[hostname]['servicestatus']
           end
    body data.send("to_#{@format}")
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
  get "/status/:hostname" do |hostname|
    body (if @output == :state
            @status[hostname]['hoststatus'].extract!("host_name", "current_state")
          else
            @status[hostname]['hoststatus']
          end).send("to_#{@format}")
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
  get "/status" do
    case @output 
    when :state
      @status.each { |k,v| @status[k] = v['hoststatus'].extract!("host_name", "current_state") }
    when :list
      @status = @status.keys
    end
    body @status.send("to_#{@format}")
  end


  ##
  # @method get_api
  #
  # Provide information about API routes 
  #
  get "/api" do 
    body self.api.send("to_#{@format}")
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
