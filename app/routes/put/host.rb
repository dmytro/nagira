#
# PUT routes for host status.
#
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
  #          => {"result": true, "object": [{"data": {"host_name":"svaroh",
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
    update_host_status @input.first.merge({
      'host_name' => params['host_name']
    })
  end

  # Same as /_status/:host_name (Not implemented)
  #
  # @method put__host_status_host_name
  # @overload put("/_host_status/:host_name")
  #
  put "/_host_status/:host_name" do
    "Not implemented: TODO"
  end

end
