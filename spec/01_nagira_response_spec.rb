require_relative '../app.rb'
require 'rack/test'
require 'pp'

describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end

  TOP_PAGES = %w{ config objects status }
  FORMATS = %w{ xml yaml json}
  DEFAULT_FORMAT = ::Nagira.settings.format
  TYPES   = %w{state list}

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

            it "/#{page}.#{format} response should be the same as /#{page}" do
              pending
            end

          end
        end
      end
    end

    context "/config" do 

      before do
        get "/config.json"
        @data = JSON.parse last_response.body
      end

      context "check some important keys in Nagios configuration" do

        string_keys = %w{ log_file object_cache_file
        resource_file status_file nagios_user nagios_group }

        string_keys.each do |key| it "attribute #{key} should be string" do
            @data[key].should be_a_kind_of String
          end 
        end

        array_keys = %w{  cfg_file cfg_dir }

        array_keys.each do |key| it "attribute #{key} should be array" do
            @data[key].should be_a_kind_of Array
          end 
        end

      end
    end # /config

    context "/objects" do
      context "objects existense" do 
        before do 
          get "/objects"
          @data = JSON.parse last_response.body
        end

        %w{  hosts services contacts timeperiods }.each do |obj|
          it "#{obj} should exist" do 
            @data[obj].should be_a_kind_of Array
          end
        end

          context "individual route for" do
          %w{  hosts services contacts timeperiods }.each do |obj|
            
            it "#{obj} should exist" do 
              get "/objects/#{obj}.json"
              JSON.parse(last_response.body).should be_a_kind_of Array
            end
          end
        end
      end
    end
  end
end
