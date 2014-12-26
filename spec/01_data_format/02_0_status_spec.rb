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
  # GET /status
  # -----------------------------

  context 'data types' do

    {
      "/_status"  => Hash,
      "/_status/_state" => Hash,
      "/_status/_list" => Array
    }.each do |url,klas|

      it "#{url} should return #{klas}" do
        get "#{url}.json"
        expect(JSON.parse(last_response.body)).to be_a_kind_of klas
      end

    end


  end
end
