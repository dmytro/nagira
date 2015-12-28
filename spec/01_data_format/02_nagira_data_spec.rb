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

require 'spec_helper'

describe Nagira do

  include Rack::Test::Methods

  def app
    @app ||= Nagira
  end

  #
  # GET /objects/...
  # ----------------------------------------
  context "GET /objects" do

    before :all do
      get "/_objects"
      @data = JSON.parse last_response.body

      # make sure these exist
      # Painful.... don't kow how to make it work
      # $allkeys =  (%w{host service contact timeperiod} + @data.keys).uniq
    end


    context 'GET hash key' do
      %w{host service contact timeperiod}.each do |obj|
        it "objects[#{obj}] should exist" do
          expect(@data[obj]).to be_a_kind_of Hash
        end
      end
    end

      %w{host service contact timeperiod}.each do |obj|
      context "GET /_objects/#{obj}" do

        it "should respond to HTTP resuest" do
          get "/_objects/#{obj}.json"
          expect(last_response).to be_ok
        end

        it "response to /objects/#{obj} should be Hash" do
          get "/_objects/#{obj}.json"
          expect(JSON.parse(last_response.body)).to be_a_kind_of Hash
        end
      end
    end
  end
  # /objects --------------------


  #
  # GET /status
  # -----------------------------

  context 'GET /status' do
    before :all do
      get "/_status"
      @data = JSON.parse last_response.body

      get "/_status/_list"
      @list = JSON.parse last_response.body

      get "/_status/_state"
      @state = JSON.parse last_response.body
    end

    context "Compare list of hostsnames" do
      it "full and state are the same " do
        expect(@data.keys).to eq @state.keys
      end

      it "list and state are the same " do
        expect(@list).to eq @state.keys
      end

      it "list and data are the same " do
        expect(@list).to eq @data.keys
      end
    end

  end
end
