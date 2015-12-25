class Nagira < Sinatra::Base
  class HostStatusController
    include OutputTypeable

    def initialize(status, output: nil, hostname: nil)
      @status = status
      @output = output
      @hostname = hostname
    end

    # Type of the output for data: full, normal, state or list
    attr_accessor :output

    # [optional] hostname, if not given then return data for all hosts
    attr_accessor :hostname

    # Get host status, depending on the type of output required: full,
    # normal, state or list.
    def get
      case
      when full?  ; then status
      when state? ; then state
      when list?  ; then list

      else normal
      end
    end

    # Update host status
    def put(params)
      Writer.new(:PROCESS_HOST_CHECK_RESULT)
        .put(with_host(params))
    end

    def with_host(params)
      params.merge({'host_name' => hostname})
    end

    # Status data: for all hosts or single host if hostname provided.
    #
    # @return [Hash] Nagios parsed data (Parser.status)
    def status
      if hostname
        { hostname => @status[hostname] }
      else
        @status
      end
    end

    private

    # List of hosts
    def list
      status.keys
    end

    # Short state of the host: only hostname and state
    def state
      normal.inject({  }) { |hash,elem|
        hash[elem.first] = elem.last.slice("host_name", "current_state")
        hash
      }
    end

    # Normal is 'reduced' hoststate: excluding services, i.e. only
    # hoststate
    def normal
      status.inject({  }) do |hash,elem|
        hash[elem.first] = elem.last['hoststatus']
        hash
      end
    end

  end

end

#  LocalWords:  hoststate hoststatus
