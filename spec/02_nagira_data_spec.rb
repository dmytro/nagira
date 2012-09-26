#
# More deep data structure checks
#

# Check these routes
# ----------------------------------------
#   get "/config" do 
#   get "/objects" do
#   get "/objects/:type" do |type|
#   get "/objects/:type/:name" do |type,name|
#   get "/status/:hostname/services/:service_name" do |hostname,service|
#   get "/status/:hostname/services" do |hostname|
#   get "/status/:hostname" do |hostname|
#   get "/status" do
#   get "/api" do 

require_relative '../app.rb'
require 'rack/test'
require 'pp'


describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end

  #
  # GET /objects/...
  # ----------------------------------------
  context "/objects" do

    before :all do 
      get "/_objects"
      @data = JSON.parse last_response.body

      # make sure these exist
      # Painful.... don't kow how to make it work
      # $allkeys =  (%w{host service contact timeperiod} + @data.keys).uniq
    end

      
    context 'hash key' do
      %w{host service contact timeperiod}.each do |obj|
        it "objects[#{obj}] should exist" do 
          @data[obj].should be_a_kind_of Hash
        end
      end
    end
      
      %w{host service contact timeperiod}.each do |obj|
      context "/_objects/#{obj}" do
        
        it "should respond to HTTP resuest" do 
          get "/_objects/#{obj}.json"
          last_response.should be_ok
        end
        
        it "response to /objects/#{obj} should be Hash" do 
          get "/_objects/#{obj}.json"
          JSON.parse(last_response.body).should be_a_kind_of Hash
        end
      end
    end
  end 
  # /objects --------------------
  

  #
  # GET /status
  # -----------------------------

  context '/status' do 
    before :all do 
      get "/_status"
      @data = JSON.parse last_response.body

      get "/_status/_list"
      @list = JSON.parse last_response.body

      get "/_status/_state"
      @state = JSON.parse last_response.body
    end
    
    context "list of hosts should be the same" do 
      it "full and state" do 
        @data.keys.should == @state.keys
      end

      it "list and state" do 
        @list.should == @state.keys
      end

      it "list and data" do 
        @list.should == @data.keys
      end
    end

  end
end
