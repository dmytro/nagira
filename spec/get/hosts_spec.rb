require 'spec_helper'

describe Nagira do 
  
  set :environment, ENV['RACK_ENV'] || :test
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end
  
  context "/_hosts" do 

    before :each do 
      get "/_status/_list"
      @data = JSON.parse(last_response.body)
    end

    it "return hosts list " do
        @data.should be_a_kind_of Array
    end

    it "hostname is a string" do 
      @data.first.should be_a_kind_of String
    end

  end

    
end
