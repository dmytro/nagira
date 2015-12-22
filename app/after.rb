class Nagira < Sinatra::Base
  # Bad request. If you are requesting for the route that does not
  # exist.
  after do
    if response.status == 404
      halt [404, {
              :message => "Bad route or request",
              :error => "HTTP::Notfound"
            }.send("to_#{@format}")
           ]
    end
  end
  ##
  # @method   object_not_found
  # @overload after("Object not found or bad request")
  #
  # If result-set of object/status search is empty return HTTP 404 .
  # This can happen when you are requesting status for not existing
  # host and/or service.
  #
  after do
    if response.body.empty?
      halt [404, {
              :message => "Object not found or bad request",
              :error => "HTTP::Notfound"
            }.send("to_#{@format}")
           ]
    end
  end

  ##
  # @method argument_error
  # @overload after("ArgumentError")
  #
  # Return 400 if result of PUT operation is not success.
  #
  after do
    if request.put? && ! response.body[:result]
      halt [400, response.body.send("to_#{@format}") ]
    end
  end

  ##
  # @method   convert_to_active_resource
  # @overload after("Return Array for ActiveResouce routes")
  #
  #
  after do
     response.body = response.body.values if @active_resource && response.body.is_a?(Hash)
  end

  ##
  # @method   return_jsonp_data
  # @overload after("Return formatted data")
  #
  # If it's a JSON-P request, return its data with prepended @callback
  # function name. JSONP request is detected by +before+ method.
  #
  # If no callback paramete given, then simply return formatted data
  # as XML, JSON, or YAML in response body.
  #
  # = Example
  #
  #     $ curl  'http://localhost:4567/?callback=test'
  #         test(["{\"application\":\"Nagira\",\"version\":\"0.1.3\",\"url\":\"http://dmytro.github.com/nagira/\"}"])
  #
  after do
    body(
         if @callback
           "#{@callback.to_s} (#{response.body.to_json})"
         else
           response.body.send "to_#{@format}"
         end
        )
  end
end
