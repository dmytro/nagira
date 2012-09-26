require_relative '../app.rb'
require 'rack/test'
require 'pp'


describe Nagira do 

  set :environment, ENV['RACK_ENV'] || :test

  include Rack::Test::Methods
  
  def app
    @app ||= Nagira
  end



  context "API data" do
    before :all do 
      get "/_api.json"
      @data = JSON.parse last_response.body
    end

    it "should be array" do 
      @data.should be_a_kind_of Hash
    end

    METHODS = %w{ GET PUT POST DELETE}

    context "routes" do 
      
      METHODS.each do |method|
        
        context method do 
          it "routes should be an Array" do
            @data[method].should be_a_kind_of Array if @data[method]
          end
          
          it "should star with slash" do
            if @data[method]
              @data[method].each do |path|
                path.should =~ /^\//
              end
            end
          end

        end
      end
    end
  end
end
