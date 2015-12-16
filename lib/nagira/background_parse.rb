require 'nagios'
require 'singleton'

module Nagios
  ##
  # Background parsing of status.dat file in separate thread. Runs on
  # regular intervals defined by :ttl
  #
  class BackgroundParser
    include Singleton

    attr_accessor :use_inflight_flag

    class << self
      ##
      # @ttl (Fixint, seconds) defines re-parsing interval for the
      # BackgroundParser.
      #
      # Set @@ttl after initialisation, to be able to pass
      #  configuration varialbles.
      #
      # @see start=
      #
      # Example:
      #     Nagios::BackgroundParser.ttl = ::DEFAULT[:ttl].to_i
      #     Nagios::BackgroundParser.start = ::DEFAULT[:start_background_parser]
      #     Nagios::BackgroundParser.instance.run
      #
      def ttl= ttl
        @ttl = ttl
      end

      ##
      # @start (Boolean) defines whether BackgroundParser should be
      # started.
      #
      # Set :start variable after initialisation, to be able to pass
      #  configuration values.
      #
      # @see ttl=
      #
      # Example:
      #     Nagios::BackgroundParser.ttl = ::DEFAULT[:ttl].to_i
      #     Nagios::BackgroundParser.start = ::DEFAULT[:start_background_parser]
      #     Nagios::BackgroundParser.instance.run
      #
      def start= start
        @start = start
      end

      ##
      # Is BackgroundParser configured to run?
      def configured?
        @ttl > 0 && @start
      end

      ##
      # Is BG parser thread running
      #
      def alive?
        !@bg.nil? && @bg.alive?
      end

      ##
      # See alive?
      def dead?
        !alive?
      end

      ##
      # Start BG Parser if it's configured to run and TTL is defined
      def run
        if configured? && dead?
          puts "[#{Time.now}] Starting background parser thread with interval #{@ttl} sec"
          @bg = Thread.new {
            loop {
              if  @use_inflight_flag = !@use_inflight_flag
                $nagios[:status].parse
              else
                $nagios[:status_inflight].parse
              end
              sleep @ttl
            }
          }
        end
      end


    end
  end
end
