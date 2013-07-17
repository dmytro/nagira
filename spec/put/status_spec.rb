require 'spec_helper'
require_relative 'support'

describe Nagira do 
  
  set :environment, :test       #  This is potentially desctructive test, run only in  test mode
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end
  
  let (:content_type) {  {'Content-Type' => 'application/json'} }
  let (:nagios_cmd )  { $nagios[:commands].path }
  before :all do
    get "/_status/_list.json"

    @host = JSON.parse(last_response.body).first
    get "/_status/#{@host}/_services.json"

    @data = {
      "service_description" => "Host Service", 
      "return_code" => 0, 
      "plugin_output" => "Plugin said: Bla" 
    }

  end

  before :each do 
    File.delete nagios_cmd rescue nil
  end

  # ==================================================================
  # Tests
  #

  context "/_status/:host_name/_services" do
  end


  context "/_status/:host_name/_services/:service_description" do
    let(:url) { "/_status/#{@host}/_services/PING" }
    before do
      put url, { return_code: 0, plugin_output: "All OK"}.to_json, content_type
    end
    
    it_should_behave_like :json_response
    it "writes status" do 
      last_response.should be_ok
    end
  end


  context "Updates /_status/:host/_services" do    
    let (:url) { "/_status/#{@host}/_services" }
    
    context "valid host" do

      it_should_behave_like :json_response

      it "over-writes JSON hostname from URL" do
        pending
      end
      
      it "update with valid data" do 
        last_response.should be_ok
      end
      
      it "writes to nagios.cmd file" do
        File.should_not exist(nagios_cmd)
        put url, @data.to_json, content_type
        File.should exist(nagios_cmd)
        File.read(nagios_cmd).should =~ /^\[\d+\] PROCESS_SERVICE_CHECK_RESULT;#{@host}/
      end
      
      it 'Fails with missing data' do 
        @data.keys.each do |key|
          data = @data.dup
          data.delete key
          put url, data.to_json, content_type
          last_response.status.should be 400
        end
      end

      it "ignores 404 for some services" do 
        pending
      end

    end                       # valid host

    context 'host does not exist' do
      let (:url) { "/_status/some_nonexisting_host/_services" }

      it_should_behave_like :json_response
      it {  pending "Add validaton for host existence in Ruby-Nagios for PUT"}

#       it "fails with valid data" do 
#       end
#       it 'fails with invalid data' do 
#       end

    end                         # host does not exist
  end                           # update /_hosts
end
