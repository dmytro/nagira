class Nagira < Sinatra::Base

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
    Logger.log("BackgroundParser is not running", :warning) if
      BackgroundParser.configured? && BackgroundParser.dead?

    Parser.parse

    @status = Parser.status['hosts']
    @objects = Parser.objects

    #
    # Add plural keys to use ActiveResource with Nagira
    #
    @objects.keys.each do |singular|
      @objects[singular.to_s.pluralize.to_sym] = @objects[singular]
    end
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
  # @method   detect_ar_type
  # @overload before('detect ActiveResource mode')
  #
  # Detect if this a request for ActiveResource PATH
  #
  before do
    @active_resource = request.path_info =~ %r{^#{Nagira::AR_PREFIX}/}
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
  #      GET /_api?callback=jQuery12313123123 # @callback == jQuery12313123123
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

  # @method parse_input_data
  # @overload before("Parse PUT request body")
  #
  # Process the data before on each HTTP request.
  #
  # @return [Array] @input Sets @input instance variable.
  #
  before do
    if request.put?
      data = request.body.read
      @input = case @format
              when :json then JSON.parse    data
              when :xml  then Hash.from_xml data
              when :yaml then YAML.load     data
              end
      # Make sure we always return an Array
      @input = [@input] if @input.is_a? Hash
      @input
    end
  end

end
