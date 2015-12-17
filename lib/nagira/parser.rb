class Nagira < Sinatra::Base
  # Singleton class, that handles parsing of the Nagios data. This
  # class uses another singleton class BackgroundParser for repeating
  # parsing of the files in background thread.
  #
  # Example usage:
  #
  #    Parser.config   = < path to nagios.cfg file>
  #    Parser.status   = < path to status.cfg file>
  #    Parser.objects  = < path to object_cache file>
  #    Parser.commands = < path to the external command execution file >
  #
  class Parser
    include Singleton

    def initialize
      @state = OpenStruct.new
    end

    # State structure keep all the Nagios parsed state information for
    # :objects, :status, :config, etc. as well as "inflight" data.
    attr_accessor :state

    class << self

      # Detect which half of the data should be returned. There's a
      # pissiblility that during request data are bing parsed, which
      # can result in incomplete or broken data. This ensures, that
      # only data that are not being parsed now returned.
      def inflight?
        BackgroundParser.inflight?
      end

      ##
      # Construct file symbol, based on in flight status.
      #
      # @see inflight?
      def with_inflight?(file)
        (inflight? ? "#{file}_inflight" : file).to_sym
      end

      # Return state object
      def state
        instance.state
      end

      ##
      # If BackgroundParser is not running, then parse files,
      # otherwise do nothing, as the data are already parsed by the
      # BG.
      def parse(files = %i{config objects status})
        return if BackgroundParser.alive?
        files
          .map { |f| state.send(f) }
          .map(&:parse)
      end

      ##
      # Configuration object of the Nagios and Nagira parser. Create
      # new configuration and parse it at the time of creation.
      #
      def config=(config)
        state.config = Nagios::Config.new(config)
        state.config.parse
      end

      # Return parsed configuration.
      def config
        state.config
      end

      # Create new data structure for the host status data
      #
      # @param status_file [String] PATH to the file
      def status=(status_file)
        state.status = Nagios::Status.new(status_file)
      end

      # Return parsed hosts status. Depending on the inflight flag
      # return either "A" or "B" set of data.
      def status
        state
          .send(with_inflight?(:status))
          .status
      end

      # Create new data structure for parsed object_cache file
      # information.
      #
      # @param objects_file [String] PATH to the file
      def objects=(objects_file)
        state.objects = Nagios::Objects.new(objects_file)
      end

      def objects
        state
          .send(with_inflight?(:objects))
          .objects
      end

      def commands=(commands_file)
        state.commands = Nagios::ExternalCommands.new(commands_file)
      end

      def commands
        state.commands
      end
    end
  end
end
