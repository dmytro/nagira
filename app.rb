#!/usr/bin/env ruby

$: << File.dirname(__FILE__)
require 'lib/nagira'

##
#
# Note:: Mostly methods with comments Sinatra DSL :before method are not actually
#        method definitions. They are Sinatra DSL methods
#        calls. Looking for better means to document DSL methods with
#        YARD.
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
  # @method parse_nagios_files  
  #
  # Sinatra DSL :before method
  #

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
  # @method BEFORE_strip_extensions 
  #
  # Sinatra DSL :before method
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
  # @method BEFORE_strip_output_type 
  #
  # Sinatra DSL :before method
  #
  # Detect and strip output type (@output) from HTTP route if it is
  # provided. Full list of output tuypes is :list, :state or
  # :full. 
  #
  # Output type in HTTP route can be 'list' or 'state'. If no output
  # type specfied it is set to :full.
  #
  # = Examples
  #
  #     GET /objects/list     # => :list
  #     GET /status/state     # => :state
  #     GET /status/:hostname # => :full
  #
  # @see API
  before do
    request.path_info.sub!(/\/(list|state)$/, '')
    @output = ($1 || :full).to_sym
  end

  ##
  # @method AFTER_object_not_found
  # Sinatra :after DSL method
  #
  # If result-set of object/status search is empty return HTTP
  # 404. This can happen when you are requesting status for not
  # existing host and/or service.
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

  ##
  # @method GET_config
  # 
  # Nagira API
  # TODO: Not implemented
  #
  # Retrieves Nagios configuration hash.
  # @see API
  get "/config" do 

  end


  ##
  # @method GET_objects
  #
  # Get full list of Nagios objects. Returns hash containin all
  # configured objects in Nagios: hosts, hostgroups, services,
  # contacts. etc.
  #
  # Nagira API
  get "/objects" do
    
    body (@output == :list ? 
          @objects.keys.send("to_#{@format}") : 
          @objects.send("to_#{@format}")) rescue NoMethodError nil
  end

  # Single type
  get "/objects/:type" do |type|
    begin
      data = @objects[type.to_sym]
      data = data.keys if @output == :list
      body ( data ? data : nil ).send("to_#{@format}")
    rescue NoMethodError
      nil
    end
  end

  # Single object
  get "/objects/:type/:name" do |type,name|
    begin
      body @objects[type.to_sym][name].send("to_#{@format}")
    rescue NoMethodError
      nil
    end
  end


  # Routes for service information

  # === GET /status/:hostname/services/:service_name
  # Full or short status information for particular service on single
  # host
  # /list option is ignored
  get "/status/:hostname/services/:service_name" do |hostname,service|
    body (if @output == :state
            @status[hostname]['servicestatus'][service].extract!("hostname", "service_description", "current_state")
          else
            @status[hostname]['servicestatus'][service]
          end).send("to_#{@format}")
  end

  # All services for single host: 
  # :full, :state or :list
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
  # - :state - hostname and current_state
  # - :full  - full hoststatus
  get "/status/:hostname" do |hostname|
    body (if @output == :state
            @status[hostname]['hoststatus'].extract!("host_name", "current_state")
          else
            @status[hostname]['hoststatus']
          end).send("to_#{@format}")
  end

  #
  # All hosts status
  # - :state - only hostname and current_state
  # - :list  - list of hostnames
  # - :full status of all hosts and services (TODO)
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


  # TODO: provide information about API routes
  get "/api" do 
    [501, "TODO: Not implemented"]
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
