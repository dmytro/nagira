require 'spec_helper'
require_relative 'support'
require 'pp'

describe Nagira do

  dont_run_in_production(__FILE__) and break

  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  before :all do
    get "/_status/_list.json"
    @host = JSON.parse(last_response.body).first
  end

  let (:content_type) {  {'Content-Type' => 'application/json'} }
  let (:host) { @host }
  let (:input) {
    {
      "status_code" => 0,
      "plugin_output" => "Plugin said: Bla"
    }
  }

  # --------------------------------------------
  # Tests
  #

  context "/_status" do
    it { pending "Not implemented"; fail }
  end                           # ----------- "/_status" do

  context "/_status/:host_name" do
    let (:url) { "/_status/#{host}"}

    before (:each) do
      put url, input.to_json, content_type
    end

    it_should_behave_like :put_status

    it "should fail with missing data" do
      input.keys.each do |key|
        (inp = input.dup).delete key
        put url, inp.to_json, content_type
        expect(last_response.status).to eq 400
      end
    end

    context "/_host_status/:host_name" do
      it { pending "Not implemented" ; fail }
    end                         # ----------- "/_host_status/:host_name"


  end                           #  ----------- /_status/:host

end
