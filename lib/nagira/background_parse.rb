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
    attr_accessor :use_inflight_flag

    class << self

      ##
      # Target data structure (i.e. $nagios hash for example) which is
      # updated by BackgroundParser.
      #
      def target=(target)
        @target = target
      end

      def parse(*files)
        files.each do |f|
          f.send(:parse)
        end
      end
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


      def with_inflight?(file)
        inflight? ? "#{file}_inflight".to_sym : file
      end

    end
  end
end
