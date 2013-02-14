module Nagios

  require 'nagira/timed_parse'
  require 'nagira/background_parse'

  # Extensions to Nagios::Status and Objects classes for use with
  # Nagira: keep track of file modification times and parse only
  # changed files.
  class Config
    include Nagios::TimedParse
  end

  class Status
    include Nagios::TimedParse
  end

  class Nagios::Objects
    include Nagios::TimedParse
  end
end
