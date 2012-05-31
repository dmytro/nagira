require 'sinatra'

$: << File.dirname(File.dirname(__FILE__))

require 'config/defaults'
require 'config/environment'

describe "Configuration" do 

  it "file nagios.cfg should exist" do
    File.exists?(settings.nagios_cfg).should be true
  end

  it "file nagios.cfg should be parseable" do
    pending "Do it later"
  end


end
