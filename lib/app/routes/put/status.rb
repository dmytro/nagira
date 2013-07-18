#
# PUT method routes for services status.
#
class Nagira < Sinatra::Base

  # @method put_status_host_name_services
  # @overload put("/_status/:host_name/_services")
  #
  # Update multiple services on the same host.
  #
  # Hostname from URL always overrides host_name if it's is provided
  # in the JSON data.
  #
  # == Example return JSON data
  #
  #   $ curl -i -H "Accept: application/json" -d @dat_m.json -X PUT
  #   http://localhost:4567/_status/svaroh/_services
  #
  #     {"result"=>true,
  #      "object"=>
  #       [{"data"=>
  #          {"return_code"=>0,
  #           "plugin_output"=>"All OK",
  #           "service_description"=>"PING",
  #           "host_name"=>"archive",
  #           "action"=>"PROCESS_SERVICE_CHECK_RESULT"},
  #         "result"=>true,
  #         "messages"=>[]}]}
  #
  # == Example JSON for submit
  #
  # All attributes provided in the example below are requried for host
  # service status information:
  # - host_name
  # - service_description
  # - return_code
  # - plugin_output
  #
  #
  #     [{ "host_name":"viy",
  #        "service_description":"PING",
  #        "return_code":"0",
  #        "plugin_output":"64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.046 ms "
  #       },
  #
  #     {"host_name":"svaroh",
  #        "service_description":"Apache",
  #        "return_code":"2",
  #        "plugin_output":"HTTP GEt failed"
  #        }
  #       ]
  #
  #
  put "/_status/:host_name/_services" do

    data, result = [], true

    @input.each do |datum|
      # FIXME - this calls update for each service. Should be batching them together
      update = update_service_status(
                                      datum.merge({ 
                                                    'host_name' => params['host_name']
                                                  })
                                      )
      data << update[:object]
      result &&= update[:result]
    end
    @data = { result: result, object: data }
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
