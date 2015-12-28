require 'spec_helper'
#
# Specs for returned data for /_status/* endpoints.
#
# Endpoint checks (i.e. check HTTP success) are in  endpoints_spec.rb

describe Nagira do

  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  before :all do
    get "/_status/_list.json"
    @host = JSON.parse(last_response.body).first
  end

  context "GET /_hosts/:host/_services" do

    before :each do
      get "/_status/#{@host}/_services"
      @data = JSON.parse(last_response.body)
    end

    it "return services list " do
        expect(@data).to be_a_kind_of Hash
    end
  end


end
