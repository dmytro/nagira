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
#     - +/_full+ - Show full status information. When used in 
#       /_status/_full call will display full hoststaus and 
#       servicestatus information for each host.
#       
#

require_relative 'lib/nagira'

##
# Main class of Nagira application implementing RESTful API for
# Nagios.
#
class Nagira < Sinatra::Base

  set :app_file, __FILE__

  ##
  # Do some necessary tasks at start and then run Sinatra app.
  #
  configure do 
    
    $nagios = { }
    $nagios[:config]  = Nagios::Config.new Nagira.settings.nagios_cfg
    $nagios[:config].parse

    $nagios.merge!({ 
                    status: Nagios::Status.new(  Nagira.settings.status_cfg || 
                                                 $nagios[:config].status_file
                                                 ),
                    objects: Nagios::Objects.new( Nagira.settings.objects_cfg || 
                                                  $nagios[:config].object_cache_file
                                                  ),
                    commands: Nagios::ExternalCommands.new( Nagira.settings.command_file || 
                                                            $nagios[:config].command_file
                                                            )
                  })

    puts "[#{Time.now}] -- Starting Nagira apllication"
    $nagios.keys.each do |x|
      puts "[#{Time.now}] -- Using nagios file #{x}: #{$nagios[x].path}"
    end

    $nagios[:status].parse
    $nagios[:objects].parse

    @status   = $nagios[:status].status['hosts']
    @objects  = $nagios[:objects].objects

    Nagios::BackgroundParser.new
  end


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
  # @overload before("Parse Nagios files")

  before do 

    if Nagira.settings.start_background_parser
      unless $bg.alive?
        logger.warn "Background Parser is configured to run, but is not active"
        $nagios[:config].parse
        $nagios[:status].parse
        $nagios[:objects].parse
      end
    else
      $nagios[:config].parse
      $nagios[:status].parse
      $nagios[:objects].parse
    end

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
  #     GET /_objects              # => default format
  #     GET /_objects.json         # => :json
  #     GET /_status/_list.yaml    # => :yaml
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
  #     GET /_status            # => :normal
  #
  before do
    request.path_info.sub!(/\/_(list|state|full)$/, '')
    @output = ($1 || :normal).to_sym
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
  # GET /_api?callback=jQuery12313123123 # @callback == jQuery12313123123
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
    # return unless request["REQUEST_METHOD"] == 'PUT'
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
  # @overload after("Return formatted data")
  #
  # If it's a JSON-P request, return its data with prepended @callback
  # function name. JSONP request is detected by +before+ method.
  #
  # If no callback paramete given, then simply return formatted data
  # as XML, JSON, or YAML in response body.
  #
  # = Example
  #
  #     $ curl  'http://localhost:4567/?callback=test'
  #         test(["{\"application\":\"Nagira\",\"version\":\"0.1.3\",\"url\":\"http://dmytro.github.com/nagira/\"}"])
  #
  after do
    body( @callback ? "#{@callback.to_s} (#{@data.to_json})" : @data.send("to_#{@format}") )
  end

  require_relative "app/routes/get/config"
  require_relative "app/routes/get/objects"
  require_relative "app/routes/get/status"

  require_relative "app/routes/put"
  require_relative "app/routes/put/status"



  ##
  # @method get_api
  # @overload get(/_api)
  #
  # Provide information about API routes 
  #
  get "/_api" do 
    @data = self.api
    nil
  end


  ##
  # @method get_runtime_config
  # @overload get(/_runtime)
  #
  # Print out nagira runtime configuration 
  get "/_runtime" do 
    @data = {
      application: self.class,
      version: VERSION,
      runtime: { 
        environment: Nagira.settings.environment,
        home: ENV['HOME'],
        user: ENV['LOGNAME'],
        nagiosFiles: $nagios.keys.map {  |x| {  x =>  $nagios[x].path }}
      }
    }
    nil
  end

  # @method get_slash
  # @overload get(/)
  #
  # Returns application information: name, version, github repository. 
  get "/" do
    @data = {
      :application => self.class,
      :version => VERSION,
      :source => GITHUB,
      :apiUrl => request.url.sub(/\/$/,'') + "/_api",
    }
    nil
  end
  # Other resources in parsed status file. Supported are => ["hosts",
  # "info", "process", "contacts"]
  # get "/:resource" do |resource|
  #   respond_with $nagios.status[resource], @format
  # end

  # Start Sinatra application when not running from rack
  run! if app_file == $0
end
