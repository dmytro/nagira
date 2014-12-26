require 'spec_helper'

describe "Configuration" do

  before {
    @cfg = Nagios::Config.new(Nagira.settings.nagios_cfg)
  }

  context "nagios.cfg" do

    it { expect(File).to exist(@cfg.path) }

    it "should be parseable" do
      expect { @cfg.parse }.not_to raise_error
    end

    context "parsing nagios.cfg file" do

      before { @cfg.parse }

      it "should have PATH to objects file" do
        expect(@cfg.object_cache_file).to be_a_kind_of String
      end

      it "should have PATH to status file" do
        expect(@cfg.status_file).to be_a_kind_of String
      end

    end # parsing nagios.cfg file
  end # nagios.cfg

  context "data files" do
    before { @cfg.parse }

    context Nagios::Status do

      subject { Nagios::Status.new( Nagira.settings.status_cfg || @cfg.status_file ) }

      it { expect(File).to exist( subject.path ) }

      it "should be parseable" do
        expect { subject.parse }.not_to raise_error
      end
    end # Nagios::Status


    context Nagios::Objects do

      subject {  Nagios::Objects.new( Nagira.settings.objects_cfg || @cfg.object_cache_file) }

      it { expect(File).to exist(subject.path) }

      it "should be parseable" do
        expect { subject.parse }.not_to raise_error
      end
    end # Nagios::Objects

  end # data files

end
