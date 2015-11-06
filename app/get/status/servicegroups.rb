class Nagira < Sinatra::Base
  # @!macro  [attach] sinatra.get
  #
  #    @overload get "$1"
  #
  #    @return HTTP response. Hash formatted in the format defined by
  #         requested output type(XML, YAML or JSON).
  #


  ##
  # @method get_status_servicegroup
  #
  # Endpoint:
  # -  GET /_status/_servicegroup/:servicegroup
  #
  # Supported extensions: _state, _list
  #

  get "/_status/_servicegroup/:servicegroup" do |group_name|

    servicegroup = Servicegroup.new(group_name)

    @data = servicegroup.send(@output)
    nil
  end

end
