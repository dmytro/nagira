require_relative '../app.rb'
require 'rack/test'

describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end

  %w{ config objects status }.each do |page|
    it "should load /#{page} page" do 
      get "/#{page}"
      last_response.should be_ok
    end
    
  end

end
