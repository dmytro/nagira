require 'spec_helper'


describe "BackgroundParser" do

  before {
    Nagios::BackgroundParser.ttl = 1
    Nagios::BackgroundParser.start = true
  }

  it "is configured" do
    expect(Nagios::BackgroundParser).to be_configured
  end

  context "after start" do

    before {
      Nagios::BackgroundParser.run
      sleep 0.1
    }

    it "is running" do
      expect(Nagios::BackgroundParser).to be_alive
    end

  end
end
