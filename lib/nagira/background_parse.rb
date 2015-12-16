require 'nagios'
require 'singleton'

module Nagios
  ##
  # Background parsing of status.dat file in separate thread. Runs on
  # regular intervals defined by :ttl
  #
  class BackgroundParser
    include Singleton

    def initialize
      @use_inflight_flag = false
    end

    #  For large Nagios files there's a significant time required for
    #  the parsing, if HTTP request comes during the parsing, data
    #  could be missing. To prevent this from happening flag variable
    #  defines two sets of the parsed data, which are parsed at
    #  different sequential runs of the parser.
    attr_accessor :use_inflight_flag

    class << self

      ##
      # Target data structure (i.e. $nagios hash for example) which is
      # updated by BackgroundParser.
      #
      def target=(target)
        @target = target
      end

      ##
      # Helper to parse multiple files (status, objects, config).
      #
      # @param [Array(Object)] files to parse
      def parse(*files)
        files.each do |f|
          f.send(:parse)
        end
      end
      ##
      # \@ttl (Fixint, seconds) defines re-parsing interval for the
      # BackgroundParser.
      #
      # Set @@ttl after initialization, to be able to pass
      #  configuration variables.
      #
      # @see start=
      #
      # Example:
      #     Nagios::BackgroundParser.ttl = ::DEFAULT[:ttl].to_i
      #     Nagios::BackgroundParser.start = ::DEFAULT[:start_background_parser]
      #     Nagios::BackgroundParser.target = $nagios
      #     Nagios::BackgroundParser.run
      #
      def ttl= ttl
        @ttl = ttl
      end

      ##
      # \@start (Boolean) defines whether BackgroundParser should be
      # started.
      #
      # Set :start variable after initialization, to be able to pass
      #  configuration values.
      #
      # @see ttl=
      #
      # Example:
      #     Nagios::BackgroundParser.ttl = ::DEFAULT[:ttl].to_i
      #     Nagios::BackgroundParser.start = ::DEFAULT[:start_background_parser]
      #     Nagios::BackgroundParser.target = $nagios
      #     Nagios::BackgroundParser.run
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

      def inflight?
        @use_inflight_flag
      end

      ##
      # Start BG Parser if it's configured to run and TTL is defined
      def run
        if configured? && dead?

          puts "[#{Time.now}] Starting background parser thread with interval #{@ttl} sec"

          @target.status_inflight = Nagios::Status.new(@target[:status].path)
          @target.objects_inflight = Nagios::Objects.new(@target[:objects].path)

          parse(
            @target[:status_inflight],
            @target[:objects_inflight]
          )

          @bg = Thread.new {
            loop {
              @target[with_inflight?(:status)].parse
              @target[with_inflight?(:objects)].parse
              sleep @ttl
              @use_inflight_flag = !@use_inflight_flag
            }
          }
        end
      end

      private
      ##
      # Construct file symbol, based on in flight status.
      # @see run
      def with_inflight?(file)
        inflight? ? "#{file}_inflight".to_sym : file
      end

    end
  end
end

#  LocalWords:  ttl BackgroundParser config param Fixint
