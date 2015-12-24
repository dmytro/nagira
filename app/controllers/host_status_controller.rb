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
      normal.map { |x|
        x.slice("host_name", "current_state")
      }
    end

    def normal
      status.map {  |x| x.last['hoststatus']}
    end

  end

end
