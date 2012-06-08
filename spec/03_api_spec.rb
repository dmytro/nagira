require_relative '../app.rb'
require 'rack/test'
require 'pp'


describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end



  context "API data" do
    before :all do 
      get "/api.json"
      @data = JSON.parse last_response.body
    end

    it "should be array" do 
      @data.should be_a_kind_of Array
    end

    METHODS = %w{ get put post delete}

    context "routes" do 
      
      it "should be valid HTTP route" do
        pending
      end
    end

  end
end
