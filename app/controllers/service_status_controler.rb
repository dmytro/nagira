class Nagira < Sinatra::Base
  class ServiceStatusController

    include OutputTypeable

    # @param nagios_status [Hash] output of  the Nagios status file parser
    # @param output [Symbol(:state)] Output data: full or short state
    # @param hostname [String]
    # @param service_name [String]
    def initialize(nagios_status, output: nil, hostname: nil, service_name: nil)

      @nagios_status = nagios_status
      @output = output
      @hostname = hostname
      @service_name = service_name
      @resource = "servicestatus"
    end

    # Read all statuses of the hosts' services. Format output: full
    # service state hash, or state only: name and state.
    def get
      case
      when state?
        with_service_name
          .values
          .first
          .slice("host_name", "current_state")
      else
        with_service_name
      end
    end

    def put(params)
      Writer.new(:PROCESS_SERVICE_CHECK_RESULT).put with_service_and_host(params)
    end

    def with_service_and_host(params)
      params.merge({
        'service_description' => @service_name,
        'host_name' => @hostname
        })
    end

    private
    include HostStatusNameConcerneable

  end
end

#  LocalWords:  param servicestatus
