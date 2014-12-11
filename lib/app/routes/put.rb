class Nagira < Sinatra::Base

  # @method parse_input_data
  # @overload before("Parse PUT request body")
  # 
  # Process the data before on each HTTP request.
  #
  # @return [Array] @input Sets @input instance variable. 
  #
  before do 
    if request.put?
      data = request.body.read
      @input = case @format
              when :json then JSON.parse    data
              when :xml  then Hash.from_xml data
              when :yaml then YAML.load     data
              end
      # Make sure we always return an Array
      @input = [@input] if @input.is_a? Hash
    end
    @input
  end

  # Define helpers for put methods
  helpers do 

    # Helper to send PUT update to Nagios::ExternalCommands
    #
    # @param [Hash] params 
    # @param [Symbol] action Nagios external command name
    #
    # FIXME: This only accepts single service. Modify to use Arrays too 
    def put_update action, params
      res = $nagios[:commands].write(params.merge({ :action => action }))
      { :result => res[:result], :object => res[:data]}
    end
  end

    # Small helper to submit data to ::Nagios::ExternalCommands
    # object. For status updates sends external coond via
    # ::Nagios::ExternalCommands.send method.
    def update_service_status params
      put_update :PROCESS_SERVICE_CHECK_RESULT, params
    end

    # Small helper to submit data to ::Nagios::ExternalCommands
    # object. For host status updates sends external command via
    # ::Nagios::ExternalCommands.write method.
    def update_host_status params
      put_update :PROCESS_HOST_CHECK_RESULT, params
    end

    # Small helper to submit data to ::Nagios::ExternalCommands
    # object. For status updates sends external coond via
    # ::Nagios::ExternalCommands.send method.
    def disable_svc_notifications params
      put_update :DISABLE_SVC_NOTIFICATIONS, params
    end

    # Small helper to submit data to ::Nagios::ExternalCommands
    # object. For status updates sends external coond via
    # ::Nagios::ExternalCommands.send method.
    def enable_svc_notifications params
      put_update :ENABLE_SVC_NOTIFICATIONS, params
    end
  
end
