class Nagira < Sinatra::Base
  # Singleton class. Handles updates to the of the Nagios external commands file.
  #
  # Example usage:
  #
  #    Writer.commands = <path to the external command execution file>
  #
  class Writer

    @@commands = nil

    def initialize(action)
      @action = action
    end

    # Send PUT update to Nagios::ExternalCommands
    #
    # @param action [Symbol] Nagios external command name
    # @param params [Hash] Parsed Hash from PUT request input.
    #
    # FIXME: This only accepts single service. Modify to use Arrays too
    def put(params)

      res = @@commands.write(
        params.merge({ :action => @action })
      )
      { :result => res[:result], :object => res[:data]}
    end

    def write
    end

    # State structure keep all the Nagios parsed state information for
    # :objects, :status, :config, etc. as well as "inflight" data.
    attr_accessor :state

    class << self

      def commands=(commands_file)
        @@commands = Nagios::ExternalCommands.new(commands_file)
      end

      def commands
        @@commands
      end




    end
  end
end
