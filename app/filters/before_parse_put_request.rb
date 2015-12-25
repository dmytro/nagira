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
end
