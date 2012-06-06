require_relative '../app.rb'
require 'rack/test'
require 'xmlsimple'

describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end

  TOP_PAGES = %w{ config objects status }
  FORMATS = %w{ xml yaml json}
  TYPES   = %w{ state list}

  context "simple page load" do
    TOP_PAGES.each do |page|
      it "should load /#{page} page" do 
        get "/#{page}"
        last_response.should be_ok
      end
      

        # Check 3 different formats
        FORMATS.each do |format|
          
          it "should load '#{page}.#{format}' page" do
            get "/#{page}.#{format}"
            last_response.should be_ok
          end

      end
    end
  end

  context "data format check" do

    TOP_PAGES.each do |page|
      context page do
        
        FORMATS.each do |format|
        context format do
          
            it "header should have #{format} content-type" do
              get "/#{page}.#{format}"
              last_response.header['Content-Type'].should =~ /^application\/#{format}.*/
            end

            it "body should be in #{format}" do

              get "/#{page}.#{format}"
              case format
              when 'json'
                JSON.parse(last_response.body).should be_a_kind_of Hash
              when 'xml'
                Hash.from_xml(last_response.body).should be_a_kind_of Hash
              else 
                 YAML.load(last_response.body).should be_a_kind_of Hash
             end

            end

          end
        end
      end
    end
  end

  
end
