class Nagira < Sinatra::Base
  class HostService

    def initialize(hostname,servicename)
      @hostname = hostname
      @servicename = servicename
    end
    attr_reader :hostname, :servicename

    def status
      begin
        Parser
          .status['hosts'][hostname]['servicestatus'][servicename]
      rescue NoMethodError
        {  }
      end
    end

    alias :full :status

    def state
      status.slice('host_name', 'service_description', 'current_state')
    end

    def current_state
      status.slice('current_state')
    end

  end
end
