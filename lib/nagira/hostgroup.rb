class Nagira < Sinatra::Base
  class Hostgroup
    attr_reader :objects, :status, :name, :hostgroup, :data

    def initialize(name)
      @name      = name
      @objects   = $nagios[:objects].objects
      @status    = $nagios[:status].status['hosts']
      @hostgroup = @objects[:hostgroup][name]
      @data  = {  }
    end

    def members
      hostgroup[:members].split(",")
    end

    # i.e. both servcie and hoststatus
    def full
      members.each do |hostname|
        data[hostname] = @status[hostname]
      end
      data
    end


    def status(mode)
      members.each do |hostname|
        begin
          data[hostname] = @status[hostname][mode]
        rescue NoMethodError
          data[hostname] = {  }
        end
      end
      data
    end

    def service_status
      status 'servicestatus'
    end


    def host_status
      status 'hoststatus'
    end
  end
end
