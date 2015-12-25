class Nagira < Sinatra::Base
  class ResourceStatusController

    include OutputTypeable

    # @param nagios_status [Hash] output of  the Nagios status file parser
    # @param output [Symbol(:state, :list)] Output data: full, short state or list
    # @param hostname [String]
    # @param service_name [String]
    #
    # @param resource [String] Resource to be reported. Currently
    #     supported 'servicestatus', 'servicecomments', 'hostcomments'
    def initialize(nagios_status, output: nil, hostname: nil, service_name: nil, resource: "servicestatus")

      @nagios_status = nagios_status
      @output = output
      @hostname = hostname
      @service_name = service_name
      @resource = if resource == 'services'
                    "servicestatus"
                  else
                    resource
                  end
    end

    # Return status of the resource
    def get
      case
      when state?; then  slice
      when list?; then  list
      else
        with_service_name
      end
    end

    private

    # Narrow the status hash to include only 3 keys host_name,
    # current_state and service_description
    def slice
      with_service_name.inject({  }) do |hash, elem|
        hash[elem.first] = elem.last.slice("host_name", "current_state", "service_description")
        hash
      end
    end

    #
    # @return [Array] List of resources (services, servicecomments).
    #
    # Note: _hostcomments is an Array, return full array if status
    # data structure is not Hash.
    def list
      if status.respond_to? :keys
        status.keys
      else
        status
      end
    end

    include HostStatusNameConcerneable

  end
end

#  LocalWords:  param servicestatus servicecomments hostcomments
