$: << File.dirname(File.dirname(__FILE__))
require 'lib/nagira'

describe "Configuration" do 

  set :environment, ENV['RACK_ENV'] || :test

  before { 
    @cfg = Nagios::Config.new(Nagira.settings.nagios_cfg)
  }

  context "nagios.cfg" do

    it { File.should exist @cfg.path }
    
    it "should be parseable" do
      lambda { @cfg.parse }.should_not raise_error
    end

    context "parsing nagios.cfg file" do 

      before { @cfg.parse }
      
      it "should have PATH to objects file" do 
        @cfg.object_cache_file.should be_a_kind_of String 
      end
      
      it "should have PATH to status file" do
        @cfg.status_file.should be_a_kind_of String 
      end

    end # parsing nagios.cfg file
  end # nagios.cfg
  
  context "data files" do 
    before { @cfg.parse }
    
    context Nagios::Status do
      
      subject { Nagios::Status.new( Nagira.settings.status_cfg || @cfg.status_file ) }

      it { File.should exist( subject.path ) }
      
      it "should be parseable" do
        lambda { subject.parse }.should_not raise_error
      end
    end # Nagios::Status


    context Nagios::Objects do

      subject {  Nagios::Objects.new( Nagira.settings.objects_cfg || @cfg.object_cache_file) }

      it { File.should exist subject.path }
      
      it "should be parseable" do
        lambda { subject.parse }.should_not raise_error
      end
    end # Nagios::Objects

  end # data files

end
