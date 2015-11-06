require 'spec_helper'
describe Nagira do

  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  before :all do
    @servicegroup = "ping"
    @hosts = %w{archive kurobka airport}.sort
  end

  context  "/_status/_servicegroup/@servicegroup " do

    before do
      get "/_status/_servicegroup/#{ @servicegroup }"
      @data = JSON.parse(last_response.body)
    end

    it "returns servicegroup Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "servicegroup Hash should contain all hosts" do
      expect(@data.keys.sort).to eq @hosts
    end

  end


  context  "/_status/_servicegroup/@servicegroup/_list" do

    before do
      get "/_status/_servicegroup/#{ @servicegroup }/_list"
      @data = JSON.parse(last_response.body)
    end

    it "returns Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "services should be Array's" do
      expect(@data['kurobka']).to be_a_kind_of Array
    end

  end

  context  "/_status/_servicegroup/@servicegroup/_state" do

    before do
      get "/_status/_servicegroup/#{ @servicegroup }/_state"
      @data = JSON.parse(last_response.body)
    end

    it "returns Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "service data should contain service names" do
      expect(@data['kurobka']).to include 'SSH', 'PING'
    end

    it "service data should contain service attributes" do
      expect(@data['kurobka']['SSH']).to include 'host_name', 'service_description', 'current_state'
    end

  end

  context  "Data completeness /_status/_servicegroup/@servicegroup" do

    before do
      get "/_status/_servicegroup/#{ @servicegroup }"
      @data = JSON.parse(last_response.body)
    end

    it "returns Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "service data should contain service names" do
      expect(@data['kurobka']).to include 'SSH', 'PING'
    end

    it "service data should contain service attributes" do
      expect(@data['kurobka']['SSH']).to include 'host_name', 'service_description', 'current_state'
    end

  end

end
