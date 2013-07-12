require 'spec_helper'

describe Nagira do 
  
  set :environment, :test       #  This is potentially desctructive test, run only in  test mode
  # exit unless ENV['RACK_ENV'] == 'test'
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

    @good_data = {
      "service_description" => "Host Service", 
      "return_code" => 0, 
      "plugin_output" => "Plugin said: Bla" 
    }

  end

  before :each do 
    %x{ cat /dev/null > #{nagios_cmd}}
  end

  context "updates /_status/:host/_services" do
    
    let (:url) { "/_status/#{@host}/_services" }
    context "valid host" do
      
      it "update with valid data" do 
        put url, @good_data.to_json, content_type
        last_response.should be_ok
      end
      
      it "writes to nagios.cmd file" do 
        put url, @good_data.to_json, content_type
        File.read(nagios_cmd).should =~ /^\[\d+\] PROCESS_SERVICE_CHECK_RESULT;#{@host}/
      end
      
      it 'Fails with missing data' do 
        @good_data.keys.each do |key|
          data = @good_data
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
      
      it {  pending "Add validaton for host existence in Ruby-Nagios for PUT"}

#       it "fails with valid data" do 
#       end
#       it 'fails with invalid data' do 
#       end

    end                         # host does not exist
  end                           # update /_hosts
end
