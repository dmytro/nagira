class Nagira < Sinatra::Base
  class ServicegroupController

    ##
    # Single member of servicegroup. In Nagios configuration it is
    # defined as "<hostname>,<service>". Contructor takes straing as
    # argument.
    #
    class Member
      def initialize(string)
        member = string.split ","
        @hostname = member.first
        @servicename = member.last
      end
      attr_reader :hostname, :servicename

      def service
        @service ||= Nagira::HostService.new(hostname,servicename)
      end
      def status
        service.status
      end

      def state
        service.state
      end

    end

    def initialize(name)
      @name = name
    end
    attr_reader :name

    def objects
      @objects ||= Parser.objects
    end

    def servicegroup
      objects[:servicegroup][name]
    end

    def members
      servicegroup[:members].split(/\s+/).map do |mem|
        Member.new(mem)
      end
    end

    def by_hostname
      members.inject({ }) do |memo,item|
        memo[item.hostname] ||= []
        memo[item.hostname] << item.servicename
        memo
      end
    end
    alias :list :by_hostname

    def output(type)
      members.reduce({  }) do |memo,member|
        h,s = member.hostname, member.servicename
        memo[h] ||= {  }
        memo[h][s] = member.send(type)
        memo
      end
    end

    def status
      output(:status)
    end
    alias :normal :status

    ##
    # Shortened status informaation. Only :host_name,
    # :service_description, :current_state
    def state
      output(:state)
    end
  end
end
