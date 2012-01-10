module Nagios
  # Some extensions to @ripienar's Status class for use with Nagira.
  class Status

    # Set some minimum interval for re-parsing of the status file:
    # even if file changes often, we do not want to parse it more
    # often, then this number of seconds.

    MIN_PARSE_INTERVAL = 60

    alias_method :constructor, :initialize

    # Extend current constructor with some additional data to track file change time
    # @param [String] file Path to status file
    # @param [Fixnum] parse_interval Number of seconds between re-parsing of the file
    def initialize(file, parse_interval=MIN_PARSE_INTERVAL)
      constructor(file)

      # Time when status file was last time parsed, set it to 0 secs
      # epoch to make sure it will be parsed
      @last_parsed = Time.at(0)

      # Last time file was changed
      @last_changed = File.mtime(file)
      @parse_interval = parse_interval
    end

    alias_method :parse!, :parse

    # Extend original parse method: parse file only if it needs
    # parsing and set time of parser run to current time.
    def parse
      if need_parsing?
        parse!
        last_parsed = Time.now
      end
    end

    attr_accessor :last_parsed, :last_changed, :parse_interval

    # Return true if file is changed since it was parsed last time
    def changed?
      last_changed > last_parsed
    end

    # Check if:
    # - file changed?
    # - was it parsed recently?
    def need_parsing?
      changed? && ((Time.now - last_parsed) > parse_interval)
    end

  end
end
