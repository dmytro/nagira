module HostStatusNameConcerneable

  attr_accessor :hostname, :service_name, :resource

  def status
    @status ||=
      Nagira::HostStatusController.new(@nagios_status, hostname: hostname, output: :full)
      .status[hostname][resource]
  end

  def with_service_name
    if service_name
      { service_name => status[service_name] }
    else
      status
    end
  end
end
