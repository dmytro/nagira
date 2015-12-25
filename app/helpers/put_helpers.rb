class Nagira < Sinatra::Base


    # Small helper to submit data to ::Nagios::ExternalCommands
    # object. For status updates sends external coond via
    # ::Nagios::ExternalCommands.send method.
    def update_service_status params
      Writer.new(:PROCESS_SERVICE_CHECK_RESULT).put params
    end

end
