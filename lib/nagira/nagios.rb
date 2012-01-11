module Nagios

  # Extensions to Nagios::Status and Objects classes for use with
  # Nagira: keep track of file modification times and parse only
  # changed files.
  class Status
    include Nagios::TimedParse
  end

  class Nagios::Objects
    include Nagios::TimedParse
  end
end
