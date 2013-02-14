require 'nagios'

module Nagios
  # Keep track of last parsed time and last changed time of the
  # status/cache file to avoid parsing on each HTTP request.
  class BackgroundParser

    # If :min_parse_interval is not defined set to 0 and do not run
    # background parsing.
    #
    BG_PARSE_INTERVAL = [::DEFAULT[:min_parse_interval]-0.1,1].max || nil

    def initialize
      if BG_PARSE_INTERVAL && ::DEFAULT[:start_background_parser]
        puts "[#{Time.now}] Starting background parser thread with interval #{BG_PARSE_INTERVAL} sec"
        $bg = Thread.new {
          loop {
            $nagios ||= { :config => nil, :status => nil, :objects => nil }
            $nagios[:status]  ||= Nagios::Status.new(  Nagira.settings.status_cfg || 
                                                       $nagios[:config].status_file
                                                       )
            # Force parse if file has changed, don't use standard logic
            if $nagios[:status].changed?
              $nagios[:status].parse!
              $nagios[:status].last_parsed = Time.now
            end
            sleep BG_PARSE_INTERVAL
          } #loop
        } # thread
      end
    end
  end
end
