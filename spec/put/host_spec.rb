require 'spec_helper'

describe Nagira do 
  
  set :environment, :test       #  This is potentially desctructive test, run only in  test mode
  include Rack::Test::Methods
  def app 
    @app ||= Nagira
  end

  let (:content_type) {  {'Content-Type' => 'application/json'} }

  before :all do 
    @data = {
      "status_code" => 0, 
      "plugin_output" => "Plugin said: Bla" 
    }

    get "/_status/_list.json"
    @host = JSON.parse(last_response.body).first

  end

  context "updates /_status/:host" do 
    let (:url) { "/_status/#{@host}" }
    
    context "single check" do
      
      it "with no hostname" do
        pending
#         put url, @data, content_type

#         pp [url, @data, last_response.body]
#         last_response.should be_ok
      end

      it "with hostname" do
        put url, @data, content_type
        pp last_response.body
        last_response.should_not be_ok
      end


    end

    it "Multiple checks" do
      pending
    end

  end                           #  /_status/:host

end
