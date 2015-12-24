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

    hostname = hostname.to_i if hostname =~ /^\d+$/
    if @status && @status[hostname]
      if @output == :state
        @data = @status[hostname]['servicestatus'][service].slice("hostname", "service_description", "current_state")
      else
        @data = @status[hostname]['servicestatus'][service]
      end
    end
    @data
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
  get %r{^/_status/(?<hostname>#{hostname_regex})/_(?<service>(services|hostcomments|servicecomments))$} do |hostname,service|

    hostname = hostname.to_i if hostname =~ /^\d+$/
    key = case service
          when 'services'
            'servicestatus'
          else
            service
          end

    if @status && @status[hostname]
      case @output
      when :list
        @data = @status[hostname][key].keys
      when :state
        @data = @status.each { |k,v| @data[k] = v.slice("host_name", "service_description", "current_state") }
      else
        @data = @status[hostname][key]
      end
    end

    @data
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

    @data = @status.dup

    case
    when state?
      @data.each { |k,v| @data[k] = v['hoststatus'].slice("host_name", "current_state") }
    when list?
      @data = @data.keys
    when full?
      @data
    else
      @data.each { |k,v| @data[k] = v['hoststatus'] }
    end

    @data
  end

  # Hoststatus for single host
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


    hostname = hostname.to_i if hostname =~ /^\d+$/
    @data =  @status[hostname]['hoststatus'].dup if @status.has_key? hostname

    if @output == :state
      @data = @data.slice("host_name", "current_state")
    end

    @data
  end

end
