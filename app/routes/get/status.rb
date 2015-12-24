require_relative 'status/hostgroups'
require_relative 'status/servicegroups'

class Nagira < Sinatra::Base

  ##
  # @method get_status_hostname_services_service_name
  # @overload get("/_status/:hostname/_services/:service_name")
  #
  # @!macro hostname
  # @!macro service_name
  #
  # Full or short status information for single service on single
  # host.
  #
  # @!macro accepted
  # @!macro state
  #
  get "/_status/:hostname/_services/:service_name" do |hostname,service|
    ServiceStatusController.new(
      @status, hostname: hostname, service_name: service, output: @output
    ).get
  end

  ##
  # @method get_status_hostname_services
  # @!macro hostname
  #
  # Endpoints:
  # -  GET /_status/:hostname/_services
  # -  GET /_status/:hostname/_hostcomments
  # -  GET /_status/:hostname/_servicecomments
  #
  # Read +services+, +hostcomments+ or +servicecomments+ for single
  # host.
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  get %r{^/_status/(?<hostname>#{hostname_regex})/_(?<resource>(services|hostcomments|servicecomments))$} do |hostname,resource|

    # hostname = hostname.to_i if hostname =~ /^\d+$/
    ResourceStatusController.new(
      @status, hostname: hostname, output: @output, resource: resource
    ).get

  end

  ##
  # @method get_status
  #
  # Return all hosts status.
  #
  # If no output modifier provided, outputs full hosttatus information
  # for each host. Not including services information. When +_full+
  # modifier is provided data include hoststatus, servicestatus and
  # all comments (servicecomments and hostcomments) for hosts.
  #
  # Alias: get /_status is the same thing as get /_status/_hosts with
  # ActiveResource compatibility, i.e. for */_hosts request Nagira
  # returns array instead of hash.
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  #
  # Support for (see API):
  # - plural resources: N/A
  # - object access by ID: N/A

  get %r{^/_status(/_hosts)?$} do
    HostStatusController.new(@status, output: @output).get
  end

  # Hoststatus for single host or all services.
  #
  # @method get_status_hostname
  #
  # Endpoint
  #
  # - get "/_status/:hostname"
  #
  # @!macro hostname
  #
  # @!macro accepted
  # @!macro state
  #
  # Support for:
  # - plural resources: N/A
  # - object access by ID: NO (TODO)

  get %r{^/_status/(?<hostname>#{hostname_regex})$} do |hostname|
    HostStatusController.new(@status, output: @output, hostname: hostname).get
  end

end
