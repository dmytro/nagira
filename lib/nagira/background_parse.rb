require 'nagios'

module Nagios
  ##
  # Background parsing of status.dat file in separate thread. Runs on
  # regular intervals slightly shorter than :min_parse_interval
  #
  class BackgroundParser

    ##
    # 
    # If :min_parse_interval is not defined set to 0 and do not run
    # background parsing.
    #
    def initialize
      interval = [::DEFAULT[:min_parse_interval]-0.1,1].max || nil
      if interval && ::DEFAULT[:start_background_parser]
        puts "[#{Time.now}] Starting background parser thread with interval #{interval} sec"
        $bg = Thread.new {
          loop {
            # Force parse if file has changed, don't use standard logic
            if $nagios[:status].changed?
              $nagios[:status].parse!
              $nagios[:status].last_parsed = Time.now
            end
            sleep interval
          } #loop
        } # thread
      end
    end
  end
end
