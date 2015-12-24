class Nagira < Sinatra::Base

  ##
  # @method get_status_hostgroup
  #
  # Return full status of the hostgroup: including host status and
  # service status.
  #
  get "/_status/_hostgroup/:hostgroup" do |hostgroup|
    @data = Hostgroup.new(hostgroup).full
    nil
  end

  ##
  # @method get_status_hostgroup_service
  #
  # Endpoint:
  # -  GET /_status/_hostgroup/:hostgroup/_service
  #
  get "/_status/_hostgroup/:hostgroup/_service" do |hostgroup|
    @data = Hostgroup.new(hostgroup).service_status
    nil
  end

  ##
  # @method get_status_hostgroup_host
  # @overload get("/_status/_hostgroup/:hostgroup/_host")
  #
  # Endpoint:
  # -  GET /_status/_hostgroup/:host
  get "/_status/_hostgroup/:hostgroup/_host" do |hostgroup|
    @data = Hostgroup.new(hostgroup).host_status
    nil
  end
end
