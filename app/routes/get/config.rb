class Nagira < Sinatra::Base

  # @method get_config
  # @overload get("/_config")
  #
  # Get Nagios configuration hash form parsing main Nagios
  # configuration file nagios.cfg
  get "/_config" do
    Parser.config.configuration
  end
end
