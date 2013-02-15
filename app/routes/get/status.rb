class Nagira < Sinatra::Base

  # Status routes
  # ============================================================

  ##
  # @method get_status_hostname_services_service_name
  #
  # @!macro hostname
  # @!macro service_name
  #
  # Full or short status information for single service on single
  # host.
  #
  # @!macro accepted
  # @!macro state
  #
  get "/_status/:hostname/_services/:service_name" do |hostname,service|

    if @output == :state
      @data = @status[hostname]['servicestatus'][service].slice("hostname", "service_description", "current_state")
    else
      @data = @status[hostname]['servicestatus'][service]
    end
    nil
  end

  ##
  # @method get_status_hostname_services
  # @!macro hostname
  #
  # All services for single host.
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  get "/_status/:hostname/_services" do |hostname|

    case @output
    when :list
      @data = @status[hostname]['servicestatus'].keys
    when :state
      @data = @status.each { |k,v| @data[k] = v.slice("host_name", "service_description", "current_state") }
    else
      @data = @status[hostname]['servicestatus']
    end

    nil
  end
  
  # Hoststatus for single host
  #
  # @method get_status_hostname
  #
  # @!macro hostname
  #
  # @!macro accepted
  # @!macro state
  #
  get "/_status/:hostname" do |hostname|
    @data =  @status[hostname]['hoststatus'].dup if @status.has_key? hostname
    
    if @output == :state
      @data = @data.slice("host_name", "current_state")
    end

    nil
  end

  ##
  # @method get_status
  #
  # All hosts status. If no output modifier provided, 
  #
  # @!macro accepted
  # @!macro state
  # @!macro list
  # @!macro full
  #
  get "/_status" do
    @data = @status.dup

    case @output 
    when :state
      @data.each { |k,v| @data[k] = v['hoststatus'].slice("host_name", "current_state") }
    when :list
      @data = @data.keys
    when :full
      @data
    else
      @data.each { |k,v| @data[k] = v['hoststatus'] }
    end

    nil
  end
end
