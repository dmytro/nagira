require_relative '../app.rb'
require 'rack/test'

describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end


  FORMATS = %w{ xml yaml json}
  TYPES   = %w{ state list}

  context "simple page load" do
    %w{ config objects status }.each do |page|
      it "should load /#{page} page" do 
        get "/#{page}"
        pending "No output for config page yet" if page == 'config'
        last_response.should be_ok
      end
      

        # Check 3 different formats
        FORMATS.each do |format|
          
          it "should load '#{page}.#{format}' page" do
            get "/#{page}.#{format}"
            pending "No output for config page yet" if page == 'config'
            last_response.should be_ok
          end

        #         TYPES.each do |type|
        #           it "should load '#{page}/#{type}.#{format}' page" do
        #             get "/#{page}/#{type}.#{format}"
        #             pending "No output for config page yet" if page == 'config'
        #             last_response.should be_ok
        #           end
        #         end
      end
    end
  end
end
