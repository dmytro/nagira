require 'spec_helper'

describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end

  TOP_PAGES = %w{ _config _objects _status _api }
  FORMATS = %w{ xml yaml json}
  DEFAULT_FORMAT = ::Nagira.settings.format
  TYPES   = %w{state list}

  context "simple page load" do
    TOP_PAGES.each do |page|
      it "/#{page} should load" do 
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

            before do  
              get "/#{page}.#{format}"
              @header = last_response.header
              @body = last_response.body
            end
            
            it "Content-type: application/#{format}" do
              @header['Content-Type'].should =~ /^application\/#{format}.*/ 
            end

            it "body should have content" do
              @body.should_not be_empty
            end

            it "#{format} should be parseable" do
              case format
              when 'json'
                lambda { JSON.parse    @body }.should_not raise_error
              when 'xml'
                lambda { Hash.from_xml @body }.should_not raise_error
              when 'yaml'
                lambda { YAML.load     @body }.should_not raise_error
              end
            end
          end
          
        end
        
        context 'default format' do 
          it "/#{page}.#{Nagira.settings.format} response should be the same as /#{page}" do
            get "/#{page}.#{Nagira.settings.format}"
            a = last_response.body
            get "/#{page}"            
            b = last_response.body
            a.should eq b
          end
        end

      end
    end

    #
    # GET /config
    # ----------------------------------------
    context "/config" do 

      before do
        get "/_config.json"
        @data = JSON.parse last_response.body
      end

      context "important items in Nagios configuration" do

        # Configuration strings

        %w{ log_file object_cache_file resource_file status_file
         nagios_user nagios_group }.each do |key|

          it "attribute #{key} should be a String" do
            @data[key].should be_a_kind_of String
          end 
        end

        # Congiration arrays
        %w{cfg_file cfg_dir}.each do |key| 
          it "attribute #{key} should be an Array" do
            @data[key].should be_a_kind_of Array
          end 
        end

      end
    end # /config


  end
end
