class Nagira < Sinatra::Base
  class HostStatusController
    include OutputTypeable

    def initialize(status, output: nil, hostname: nil)
      @status = status
      @output = output
      @hostname = hostname
    end
    attr_accessor :output, :hostname

    def get
      case
      when full?  ; then status
      when state? ; then state
      when list?  ; then list

      else normal
      end
    end

    def status
      if hostname
        { hostname => @status[hostname] }
      else
        @status
      end
    end

    private


    def list
      status.keys
    end

    def state
      normal.inject({  }) { |hash,elem|
        hash[elem.first] = elem.last.slice("host_name", "current_state")
        hash
      }
    end

    def normal
      status.inject({  }) do |hash,elem|
        hash[elem.first] = elem.last['hoststatus']
        hash
      end
    end

  end

end
