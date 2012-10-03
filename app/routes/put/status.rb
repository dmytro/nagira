class Nagira < Sinatra::Base


  # Submit JSON Hash for multiple services,  on multiple hosts.
  put "/_status" do
    "Not implemented"
  end

  # Update hoststatus information only for the given host.
  put "/_status/:host_name" do
    @data = update_host_status @input.first.merge 'host_name' => params['host_name']
  end

  
  # Update multiple services on the same host.
  #
  # Hostname from URL always overrides host_name if it's is provided
  # in the JSON data.
  #
  put "/_status/:host_name/_services" do

    data = []
    @input.each do |datum|
      # FIXME - this calls update for each service. Should be batching them together
      data << update_service_status(datum.merge({ 
                                                  'host_name' => params['host_name']
                                                }))
    end
    @data = data
    nil

  end
  
  # Update single service on a single host by JSON data.
  put "/_status/:host_name/_services/:service_description" do
    @data = update_service_status \
    @input.first.merge({ 
                         'service_description' => params['service_description'],
                         'host_name' => params['host_name']
                       })
    nil
  end


  # @method put_status_as_http_parms
  # @overload put("update_status_http_pramaters")
  # 
  # Update single service status on a single host. Use data provided
  # in RESTful path as parameters.
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
