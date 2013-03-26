require 'nagios'

module Nagios
  ##
  # Background parsing of status.dat file in separate thread. Runs on
  # regular intervals slightly shorter than :ttl
  #
  class BackgroundParser

    ##
    # 
    # If :ttl is not defined set to 0 and do not run
    # background parsing.
    #
    def initialize
      interval = [::DEFAULT[:ttl],1].max || nil
      $use_inflight_status = false
      $use_inflight_objects = false
      if interval && ::DEFAULT[:start_background_parser]
        puts "[#{Time.now}] Starting background parser thread with interval #{interval} sec"
        $bg = Thread.new {
          loop {
            $use_inflight_status ? $nagios[:status].parse : $nagios[:status_inflight].parse
            $use_inflight_status = !$use_inflight_status
            sleep interval
          } #loop
        } # thread
      end
    end
  end
end
