class Nagira < Sinatra::Base

  ##
  # @method get_api
  # @overload get(/_api)
  #
  # Provide information about API routes
  #
  get "/_api" do
    ApiHelpController.show
  end

  ##
  # @method get_runtime_config
  # @overload get(/_runtime)
  #
  # Print out nagira runtime configuration
  get "/_runtime" do
    {
      application: self.class,
      version: VERSION,
      runtime: {
        environment: Nagira.settings.environment,
        home: ENV['HOME'],
        user: ENV['LOGNAME'],
        nagiosFiles: Parser.state.to_h.keys.map {  |x| {  x:  Parser.state.to_h[x].path }}
      }
    }
  end

  # @method get_slash
  # @overload get(/)
  #
  # Returns application information: name, version, github repository.
  get "/" do
    {
      :application => self.class,
      :version => VERSION,
      :source => GITHUB,
      :apiUrl => request.url.sub(/\/$/,'') + "/_api",
    }
  end

end
