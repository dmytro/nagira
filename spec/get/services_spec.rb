require 'spec_helper'

describe Nagira do 
  
  set :environment, ENV['RACK_ENV'] || :test
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end
  
  before :all do
    get "/_status/_list.json"
    @host = JSON.parse(last_response.body).first
  end

  context "/_hosts/:host/_services" do 

    before :each do 
      get "/_status/#{@host}/_services"
      @data = JSON.parse(last_response.body)
    end

    it "return services list " do
        @data.should be_a_kind_of Hash
    end
  end

    
end
