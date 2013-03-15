class Nagira < Sinatra::Base

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
  #
  # Get Nagios configuration hash form parsing main Nagios
  # configuration file nagios.cfg
  get "/_config" do
    @data = $nagios[:config].configuration
    nil
  end
end
