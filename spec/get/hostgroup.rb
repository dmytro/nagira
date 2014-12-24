require 'spec_helper'
describe Nagira do

  set :environment, ENV['RACK_ENV'] || :test
  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  before :all do
    get "/_objects/hostgroup/_list.json"
    @hostgroup = JSON.parse(last_response.body).first

    get "/_objects/host/_list.json"
    @hosts = JSON.parse(last_response.body).sort

  end

  context  "/_status/_hostgroup/@hostgroup " do

    before do
      get "/_status/_hostgroup/#{ @hostgroup }"
      @data = JSON.parse(last_response.body)
    end

    it "returns hostgroup Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "hostgroup Hash should contain all hosts" do
      expect(@data.keys.sort).to eq @hosts
    end

    it "host data should have both host and service status" do
      expect(@data['viy'].keys).to eq ['hoststatus', 'servicestatus']
    end

  end


  context  "/_status/_hostgroup/@hostgroup/_host" do

    before do
      get "/_status/_hostgroup/#{ @hostgroup }/_host"
      @data = JSON.parse(last_response.body)
    end

    it "returns Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "host data should have host status attributes" do
      expect(@data['viy'].keys).to include 'host_name', 'check_command' ,'check_interval'
    end

  end

  context  "/_status/_hostgroup/@hostgroup/_service" do

    before do
      get "/_status/_hostgroup/#{ @hostgroup }/_service"
      @data = JSON.parse(last_response.body)
    end

    it "returns Hash" do
      expect(@data).to be_a_kind_of Hash
    end

    it "service data should contain service names" do
      expect(@data['viy'].keys).to include 'SSH', 'PING'
    end

    it "service data should contain service attributes" do
      expect(@data['viy']['SSH']).to include 'host_name', 'service_description'
    end

  end

end
