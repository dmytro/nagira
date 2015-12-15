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
      @ttl = @@ttl
      @start = @@start
    end

    attr_accessor :ttl, :start, :use_inflight_flag

    class << self
      def ttl= ttl
        @@ttl = ttl
      end

      def start= start
        @@start = start
      end
    end

    def configured?
       ttl > 0 && start
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
        puts "[#{Time.now}] Starting background parser thread with interval #{ttl} sec"
        @bg = Thread.new {
          loop {
            if  use_inflight_flag = !use_inflight_flag
              $nagios[:status].parse
            else
              $nagios[:status_inflight].parse
            end
            sleep interval
          }
        }
      end
    end

  end
end
