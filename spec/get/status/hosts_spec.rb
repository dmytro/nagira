require 'spec_helper'

describe Nagira do

  include Rack::Test::Methods
  def app
    @app ||= Nagira
  end

  context "GET /_hosts" do

    before :each do
      get "/_status/_list"
      @data = JSON.parse(last_response.body)
    end

    it "return hosts list " do
        expect(@data).to be_a_kind_of Array
    end

    it "hostname is a string" do
      expect(@data.first).to be_a_kind_of String
    end

  end
end
