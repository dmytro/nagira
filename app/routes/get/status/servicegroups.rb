class Nagira < Sinatra::Base

  ##
  # @method get_status_servicegroup
  #
  # Endpoint:
  # -  GET /_status/_servicegroup/:servicegroup
  #
  # Supported extensions: _state, _list
  #

  get "/_status/_servicegroup/:servicegroup" do |group_name|
    Servicegroup.new(group_name).send(@output)
  end

end
