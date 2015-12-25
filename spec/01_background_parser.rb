require 'spec_helper'


describe "BackgroundParser" do

  before {
    Nagira::BackgroundParser.ttl = 1
    Nagira::BackgroundParser.start = true
  }

  it "is configured" do
    expect(Nagira::BackgroundParser).to be_configured
  end

  context "after start" do

    before {
      Nagira::BackgroundParser.run
      sleep 0.1
    }

    it "is running" do
      expect(Nagira::BackgroundParser).to be_alive
    end

  end
end
