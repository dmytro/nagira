class Nagira < Sinatra::Base

  # Small helper to submit data to ::Nagios::ExternalCommands
  # object. For status updates sends external coond via
  # ::Nagios::ExternalCommands.send method.
  def update_service_status params
    put_update :PROCESS_SERVICE_CHECK_RESULT, params
  end

  put "/_status" do
  end

  put "/_status/:hostname/_services" do
  end

  # Submit JSON Hash
  put "/_status/:hostname/_services/:service_description" do
  end

  
  # @method put_status_as_http_parms
  # @overload put("update_status_http_pramaters")
  # 
  # Use data provided in RESTful path as parameters.
  #
  # == Example
  #      curl  -d "test data" \
  #        -X PUT http://localhost:4567/_status/viy/_services/PING/_return_code/0/_plugin_output/OK
  #       # => ok
  put "/_status/:host_name/_services/:service_description/_return_code/:return_code/_plugin_output/:plugin_output" do 

    @data = update_service_status params
    nil
  end

  
end
