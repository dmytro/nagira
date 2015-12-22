class Nagira < Sinatra::Base

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
        nagiosFiles: $nagios.to_h.keys.map {  |x| {  x =>  $nagios[x].path }}
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



end
