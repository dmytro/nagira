class Nagira < Sinatra::Base
  # @!macro  [attach] sinatra.get
  #
  #    @overload get "$1"
  #
  #    @return HTTP response. Hash formatted in the format defined by
  #         requested output type(XML, YAML or JSON).
  #


  require 'pry'

  register Sinatra::Namespace
  namespace "/_status/_hostgroup" do

    ##
    # @method get_status_hostgroup
    #
    # Return full status of the hostgroup: including host status and
    # service status.
    #
    get "/:hostgroup" do |hostgroup|
      @data = Hostgroup.new(hostgroup).full
      nil
    end

    ##
    # @method get_status_hostgroup_service
    #
    # Endpoint:
    # -  GET /_status/_hostgroup/:hostgroup/_service
    #
    get "/:hostgroup/_service" do |hostgroup|
      @data = Hostgroup.new(hostgroup).service_status
      nil
    end

    ##
    # @method get_status_hostgroup_host
    # @overload get("/_status/_hostgroup/:hostgroup/_host")
    #
    # Endpoint:
    # -  GET /_status/_hostgroup/:host
    get "/:hostgroup/_host" do |hostgroup|
      @data = Hostgroup.new(hostgroup).host_status
      nil
    end
  end
end
