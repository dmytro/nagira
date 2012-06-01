require 'sinatra'

$: << File.dirname(File.dirname(__FILE__))

require 'config/defaults'
require 'config/environment'
require 'lib/ruby-nagios/nagios'



describe Nagira do 

  before do
    @cfg = Nagios::Config.new Nagira.settings.nagios_cfg
  end

  context "nagios.cfg file" do

    it "should exist" do
      File.exists?(Nagira.settings.nagios_cfg).should be true
    end
    
    it "should be parseable" do
      @cfg.parse.should be_a_kind_of Array
    end

    context "parsed file" do 

      before { @cfg.parse }
      
      it "should have PATH to objects file" do 
        @cfg.object_cache_file.should be_a_kind_of String 
      end
      
      it "should have PATH to status file" do
        @cfg.status_file.should be_a_kind_of String 
      end

      context "objects file " do 
    
        require 'nagios/objects'
        
        before {  
          @obj = Nagios::Objects.new @cfg.object_cache_file
          
        }
        it "should exist" do 
          File.exist?(@cfg.object_cache_file).should be true
        end
        
        it "should be parseable" do 
          @obj.parse.objects.should be_a_kind_of Hash
        end
        
        context "parsed" do 
          
        end
      end
      
      context "status file " do 
        
        require 'nagios/status'
        
        before {  
          @obj = Nagios::Status.new @cfg.status_file
          
        }
        it "should exist" do 
          File.exist?(@cfg.status_file).should be true
        end
        
        it "should be parseable" do 
          @obj.parse.status.should be_a_kind_of Hash
        end
        
        context "parsed" do 
          
        end
      end
    end
  end
end
