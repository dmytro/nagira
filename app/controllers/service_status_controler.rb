class Nagira < Sinatra::Base
  class ServiceStatusController

    include OutputTypeable

    def initialize(nagios_status, output: nil, hostname: nil, service_name: nil)

      @nagios_status = nagios_status
      @output = output
      @hostname = hostname
      @service_name = service_name
      @resource = "servicestatus"
    end

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

    private
    include HostStatusNameConcerneable

  end
end
