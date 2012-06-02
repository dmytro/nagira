$: << File.dirname(File.dirname(__FILE__))
require 'lib/nagira'

describe "Nagios config files" do 

  set :environment, ENV['RACK_ENV'] || :test

  before { @cfg = Nagios::Config.new Nagira.settings.nagios_cfg }

  context "nagios.cfg file" do

    it "should exist" do
      File.exists?(Nagira.settings.nagios_cfg).should be true
    end
    
    it "should be parseable" do
      lambda { @cfg.parse }.should_not raise_error
    end

    context "parsed file" do 

      before { @cfg.parse }
      
      it "should have PATH to objects file" do 
        @cfg.object_cache_file.should be_a_kind_of String 
      end
      
      it "should have PATH to status file" do
        @cfg.status_file.should be_a_kind_of String 
      end

      %w{ object_cache_file status_file }.each do |file|

        context "#{file}" do 
          before {  @obj = Nagios::Objects.new @cfg.send(file) }

          it "should exist" do
            File.exist?(@cfg.send(file)).should be true
          end

          it "should be parseable" do
            lambda { @obj.parse }.should_not raise_error
          end
        end

      end
    end
  end
end
