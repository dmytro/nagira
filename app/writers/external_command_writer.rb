class Nagira < Sinatra::Base
  # Singleton class. Handles updates to the of the Nagios external commands file.
  #
  # Example usage:
  #
  #    Writer.commands = <path to the external command execution file>
  #
  class Writer
    include Singleton

    def initialize
      @commands = nil
    end

    # State structure keep all the Nagios parsed state information for
    # :objects, :status, :config, etc. as well as "inflight" data.
    attr_accessor :state

    class << self

      def commands=(commands_file)
        @commands = Nagios::ExternalCommands.new(commands_file)
      end

      def commands
        @commands
      end

      def write
      end

    end
  end
end
