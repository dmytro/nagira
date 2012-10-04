class Nagira < Sinatra::Base


  # @method put_status
  # @overload put("/_status")
  #
  # Submit JSON Hash for multiple services,  on multiple hosts.
  put "/_status" do
    "TODO: Not implemented"
  end

  # @method put_status_host_name
  # @overload put("/_status/:host_name")
  #
  # Update hoststatus information only for the given host. URL
  # hostname always override hostname given in the JSON file.
  #
  # == Example
  #
  #        $ curl -i -H "Accept: application/json" -d @host.json -X
  #            PUT http://localhost:4567/_status/svaroh
  #
  #          => {"status": true, "object": [{"data": {"host_name":"svaroh",
  #          "status_code": "0", "plugin_output": "ping OK", "action":
  #          "PROCESS_HOST_CHECK_RESULT"}, "result":true, "messages": []}]}
  #
  # == Example JSON
  #
  #     {
  #      "status_code":"0",
  #      "plugin_output" : "ping OK"
  #     }                               
  put "/_status/:host_name" do
    @data = update_host_status @input.first.merge({
                                                    'host_name' => params['host_name']
                                                  })
    nil
  end

  # Same as /_status/:host_name (Not implemented)
  #
  # @method put__host_status_host_name
  # @overload put("/_host_status/:host_name")
  #
  put "/_host_status/:host_name" do 
    "Not implemented: TODO"
  end
  
  # Update multiple services on the same host.
  #
  # Hostname from URL always overrides host_name if it's is provided
  # in the JSON data.
  #
  # == Example
  #
  #   $ curl -i -H "Accept: application/json" -d @dat_m.json -X PUT
  #   http://localhost:4567/_status/svaroh/_services
  #
  #     [{"status":true, "object":[{"data":{"host_name":"svaroh",
  #     "service_description":"PING", "return_code":"0",
  #     "plugin_output":"OK",
  #     "action":"PROCESS_SERVICE_CHECK_RESULT"}, "result":true,
  #     "messages":[]}]}, {"status":true,
  #     "object":[{"data":{"host_name":"svaroh",
  #     "service_description":"Apache", "return_code":"r20",
  #     "plugin_output":"cwfailedOK",
  #     "action":"PROCESS_SERVICE_CHECK_RESULT"}, "result":true,
  #     "messages":[]}]}]%

  # == Example JSON
  #
  # [{"host_name":"viy", "service_description":"PING",
  # "return_code":"0", "plugin_output":"OK"},
  #
  # {"host_name":"svaroh", "service_description":"Apache",
  # "return_code":"r20", "plugin_output":"cwfailedOK"}]
  #
  #  @method put_status_host_name_services
  #  @overload put("/_status/:host_name/_services")
  #
  put "/_status/:host_name/_services" do

    data = []
    @input.each do |datum|
      # FIXME - this calls update for each service. Should be batching them together
      data << update_service_status(
                                    datum.merge({ 
                                                  'host_name' => params['host_name']
                                                })
                                    )
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
  # @overload  put(/_status/:host_name/_services/:service_description/_return_code/:return_code/_plugin_output/:plugin_output)
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
